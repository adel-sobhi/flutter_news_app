import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    super.firstName,
    super.lastName,
    super.email,
    super.username,
    super.image,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      username: map['username'],
      image: map['image'],
    );
  }

  factory ProfileModel.fromFirestore(Map<String, dynamic> map) {
    return ProfileModel(
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      username: map['username'],
      image: map['image'],
    );
  }
}
