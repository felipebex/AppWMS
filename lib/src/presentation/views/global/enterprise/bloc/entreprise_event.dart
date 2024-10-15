// part of 'entreprise_bloc.dart';

// @immutable
// sealed class EntrepriseEvent {}


// class EntrepriseButtonPressed extends EntrepriseEvent {
//   String entreprice;
//   EntrepriseButtonPressed(this.entreprice);

// }

// class DeleteUrl extends EntrepriseEvent {
//   final String url;
//   final String method;
//   DeleteUrl(this.url, this.method);
// }


// class LoadUrlFromDB extends EntrepriseEvent {}


// class ChangeMethod extends EntrepriseEvent {
//   final String method;
//   ChangeMethod(this.method);
// }

part of 'entreprise_bloc.dart';

@immutable
sealed class EntrepriseEvent {}


class EntrepriseButtonPressed extends EntrepriseEvent {

}

class DeleteUrl extends EntrepriseEvent {
  final int index;
  DeleteUrl(this.index);
}