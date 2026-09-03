const admin = require('firebase-admin');
const fetch = require('node-fetch');

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const messaging = admin.messaging();

async function checkNews() {
  const apiKey = process.env.NEWS_API_KEY;
  const url = `https://newsapi.org/v2/top-headlines?country=us&apiKey=${apiKey}`;

  try {
    const response = await fetch(url);
    const data = await response.json();
    if (data.articles && data.articles.length > 0) {
      const latestArticle = data.articles[0];
      const latestTitle = latestArticle.title;
      const latestUrl = latestArticle.url || '';

      const docRef = db.collection('metadata').doc('last_news');
      const docSnap = await docRef.get();

      let savedTitle = "";
      if (docSnap.exists) {
        savedTitle = docSnap.data().title;
      }

      if (savedTitle !== latestTitle) {
        console.log("New news found: " + latestTitle);

        const sourceId = latestArticle.source && latestArticle.source.id
          ? latestArticle.source.id
          : 'reuters';

        const payload = JSON.stringify({
          title: latestTitle,
          body: latestArticle.description || latestTitle,
          url: latestUrl,
          imageUrl: latestArticle.urlToImage || '',
          sourceId,
          categoryId: 'general',
          author: latestArticle.author || '',
          publishedAt: latestArticle.publishedAt || '',
          description: latestArticle.description || '',
          content: latestArticle.content || latestArticle.description || latestTitle,
        });

        // Save the full article into Firestore (latest_articles/{sourceId}) before sending the notification
        try {
          await db.collection('latest_articles').doc(sourceId).set({
            title: latestArticle.title || '',
            description: latestArticle.description || '',
            url: latestUrl,
            urlToImage: latestArticle.urlToImage || '',
            author: latestArticle.author || '',
            publishedAt: latestArticle.publishedAt || '',
            source: {
              id: latestArticle.source && latestArticle.source.id ? latestArticle.source.id : null,
              name: latestArticle.source && latestArticle.source.name ? latestArticle.source.name : null,
            },
            content: latestArticle.content || latestArticle.description || '',
            updated_at: admin.firestore.FieldValue.serverTimestamp()
          }, { merge: true });
          console.log('Saved latest article to Firestore for source:', sourceId);
        } catch (e) {
          console.error('Failed to save latest article to Firestore:', e);
          // continue — we still want to send the push notification
        }

        const message = {
          notification: {
            title: latestTitle,
            body: latestArticle.description || latestTitle,
          },
          data: {
            type: 'news',
            title: latestTitle,
            body: latestArticle.description || latestTitle,
            url: latestUrl,
            imageUrl: latestArticle.urlToImage || '',
            sourceId,
            categoryId: 'general',
            author: latestArticle.author || '',
            publishedAt: latestArticle.publishedAt || '',
            description: latestArticle.description || '',
            content: latestArticle.content || latestArticle.description || latestTitle,
            payload,
          },
          topic: "all_users"
        };

        await messaging.send(message);
        console.log("Push notification sent successfully!");

        await docRef.set({
          title: latestTitle,
          updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
      }
      else {
        console.log("No new news.");
      }
    }
  } catch (error) {
    console.error("Error checking news:", error);
    process.exit(1);
  }
}

checkNews();