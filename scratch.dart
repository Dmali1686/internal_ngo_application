import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('http://10.215.104.133:8080/api/v1/employees');
  final res = await http.get(url);
  print(res.body);
}
