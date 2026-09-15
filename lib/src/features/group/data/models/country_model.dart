// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class CountryModel {
  final String name;
  final String code;
  final String flag;
  final String codeAbbreviation;
  final List<String> states;
  CountryModel({
    required this.name,
    required this.code,
    required this.flag,
    required this.codeAbbreviation,
    required this.states,
  });

  CountryModel copyWith({
    String? name,
    String? code,
    String? flag,
    String? codeAbbreviation,
    List<String>? states,
  }) {
    return CountryModel(
      name: name ?? this.name,
      code: code ?? this.code,
      flag: flag ?? this.flag,
      codeAbbreviation: codeAbbreviation ?? this.codeAbbreviation,
      states: states ?? this.states,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'code': code,
      'flag': flag,
      'codeAbbreviation': codeAbbreviation,
      'states': states,
    };
  }

  factory CountryModel.fromMap(Map<String, dynamic> map) {
    return CountryModel(
      name: map['name'] as String,
      code: map['code'] as String,
      flag: map['flag'] as String,
      codeAbbreviation: map['codeAbbreviation'] as String,
      states: List<String>.from(map['states'] as List<String>),
    );
  }

  String toJson() => json.encode(toMap());

  factory CountryModel.fromJson(String source) =>
      CountryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return '$name $code $flag $codeAbbreviation $states';
  }

  @override
  bool operator ==(covariant CountryModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.code == code &&
        other.flag == flag &&
        other.codeAbbreviation == codeAbbreviation &&
        listEquals(other.states, states);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        code.hashCode ^
        flag.hashCode ^
        codeAbbreviation.hashCode ^
        states.hashCode;
  }
}
