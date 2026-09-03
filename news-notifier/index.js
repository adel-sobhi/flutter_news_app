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
          body: latestTitle,
          url: latestUrl,
          imageUrl: latestArticle.urlToImage || '',
          sourceId,
          categoryId: 'general',
        });

        const message = {
          notification: {
            title: "Breaking News",
            body: latestTitle,
          },
          data: {
            type: 'news',
            title: latestTitle,
            body: latestTitle,
            url: latestUrl,
            imageUrl: latestArticle.urlToImage || '',
            sourceId,
            categoryId: 'general',
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