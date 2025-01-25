import 'package:faker/faker.dart';

class FakeDataUtil {
  static final Faker _faker = Faker();

  static String getFakeImage({int width = 800, int height = 400, List<String>? keywords}) {
    return _faker.image.image(width: width, height: height, keywords: keywords ?? ['nature']);
  }

  static String getFakeTitle() {
    return _faker.lorem.sentence();
  }

  static String getFakeDescription() {
    return _faker.lorem.sentences(3).join(' ');
  }

  static String getFakeDate() {
    return _faker.date.random.toString();
  }

  static String getFakeTime() {
    return _faker.date.time().toString();
  }

  static String getFakeName() {
    return '${_faker.person.firstName()} ${_faker.person.lastName()}';
  }

// Add more methods as needed
}
