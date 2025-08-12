import 'package:equatable/equatable.dart';

abstract class RemoteArticlesEvent extends Equatable {
  const RemoteArticlesEvent();

  @override
  List<Object> get props => [];
}

class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

class RefreshFirebaseArticles extends RemoteArticlesEvent {
  const RefreshFirebaseArticles();
}