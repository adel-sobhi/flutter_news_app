

import 'package:notes_app/features/authentication/domain/entities/login_response_entities.dart';

class LoginResponseModel extends LoginResponseEntity {
  LoginResponseModel({
    super.accessToken,
    super.refreshToken,
    super.id,
    super.username,
    super.email,
    super.firstName,
    super.lastName,
    super.gender,
    super.image,
  });

  LoginResponseModel.fromJson(dynamic json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    id = json['id'];
    username = json['username'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    gender = json['gender'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['accessToken'] = accessToken;
    map['refreshToken'] = refreshToken;
    map['id'] = id;
    map['username'] = username;
    map['email'] = email;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['gender'] = gender;
    map['image'] = image;
    return map;
  }

}