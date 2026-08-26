import 'package:notes_app/features/authentication/domain/entities/register_response_entities.dart';

class RegisterResponseModel extends RegisterResponseEntity {
  RegisterResponseModel({
    super.id,
    super.firstName,
    super.lastName,
    super.email,
    super.username,
    super.image,
  });

  RegisterResponseModel.fromJson(dynamic json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    username = json['username'];
    image = json['image'];
  }
}
