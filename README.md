# Weather App с использованием библиотеки `http`

Этот проект демонстрирует использование библиотеки `http` во Flutter для выполнения HTTP-запросов к REST API. Мы создали простое приложение для отображения текущей погоды в выбранном городе. Ниже приведено описание ключевых функций библиотеки `http`, которые мы использовали, и примеры кода.

---

## **Основные функции библиотеки `http`**

### 1. **Простота и легкость использования**
Библиотека `http` предоставляет простой и понятный интерфейс для выполнения HTTP-запросов. Она идеально подходит для небольших проектов, где не требуются сложные функции, такие как перехватчики (interceptors) или отмена запросов.

#### Пример GET-запроса:
```dart
import 'package:http/http.dart' as http;

Future<void> fetchData() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
  if (response.statusCode == 200) {
    print('Данные: ${response.body}');
  } else {
    print('Ошибка: ${response.statusCode}');
  }
}
```

2. Ручная обработка ошибок
Библиотека http не предоставляет встроенной обработки ошибок, поэтому необходимо вручную проверять статус ответа и обрабатывать исключения.

Пример обработки ошибок:
```dart
try {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
  if (response.statusCode == 200) {
    print('Данные: ${response.body}');
  } else {
    print('Ошибка: ${response.statusCode}');
  }
} catch (e) {
  print('Сетевая ошибка: $e');
}
```
3. Парсинг JSON
Для работы с JSON-ответами используется встроенная библиотека dart:convert. Мы вручную парсим JSON-ответы в объекты Dart.

Пример парсинга JSON:
```dart
import 'dart:convert';

class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

Future<void> fetchData() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    final post = Post.fromJson(json);
    print('Заголовок поста: ${post.title}');
  } else {
    print('Ошибка: ${response.statusCode}');
  }
}
```

4. Отправка данных (POST, PUT, DELETE)
Библиотека http поддерживает отправку данных с помощью методов POST, PUT и DELETE.

Пример POST-запроса:
```dart
Future<void> sendData() async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'title': 'foo', 'body': 'bar', 'userId': 1}),
  );
  if (response.statusCode == 201) {
    print('Данные успешно отправлены: ${response.body}');
  } else {
    print('Ошибка: ${response.statusCode}');
  }
}
```

5. Загрузка файлов
Хотя библиотека http не поддерживает загрузку файлов "из коробки", это можно реализовать с помощью MultipartRequest.

Пример загрузки файла:
```dart
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<void> uploadFile(String filePath) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://example.com/upload'),
  );
  request.files.add(await http.MultipartFile.fromPath(
    'file',
    filePath,
    contentType: MediaType('image', 'jpeg'), // Укажите тип файла
  ));

  var response = await request.send();
  if (response.statusCode == 200) {
    print('Файл успешно загружен');
  } else {
    print('Ошибка загрузки: ${response.statusCode}');
  }
}
```
---

### Описание проекта
#### Функции приложения
- Выбор города:
  - Пользователь может выбрать город из выпадающего списка.
  - Приложение автоматически обновляет данные о погоде для выбранного города.

- Отображение погоды:
  - Приложение отображает текущую температуру, описание погоды и иконку.

- Обработка ошибок:
  - Приложение обрабатывает ошибки сети и API, выводя соответствующие сообщения.

### Используемые технологии
- http: Для выполнения HTTP-запросов.
- flutter_dotenv: Для загрузки API-ключа из .env файла.
- OpenWeatherMap API: Для получения данных о погоде.

---
### Создайте файл .env в корне проекта и добавьте в него ваш API-ключ:

```env
OPENWEATHERMAP_API_KEY=ваш_api_ключ
```
---
## Заключение
Этот проект демонстрирует основные возможности библиотеки http:
- Выполнение HTTP-запросов. 
- Парсинг JSON-ответов. 
- Обработка ошибок.
- Отображение данных в пользовательском интерфейсе.

Библиотека http отлично подходит для небольших проектов, где не требуются сложные функции, такие как перехватчики или кэширование. Для более сложных задач можно рассмотреть использование библиотеки dio.

Для получения дополнительной информации ознакомьтесь с документацией библиотеки http.