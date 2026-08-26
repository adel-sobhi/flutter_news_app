

class LoginResponseEntity {
  LoginResponseEntity({
      this.accessToken, 
      this.refreshToken, 
      this.id, 
      this.username, 
      this.email, 
      this.firstName, 
      this.lastName, 
      this.gender, 
      this.image,});


  String? accessToken;
  String? refreshToken;
  num? id;
  String? username;
  String? email;
  String? firstName;
  String? lastName;
  String? gender;
  String? image;



}