// part of 'entreprise_bloc.dart';

// @immutable
// sealed class EntrepriseState {}

// final class EntrepriseInitial extends EntrepriseState {}



// final class EntrepriseLoading extends EntrepriseState {}

// final class EntrepriseSuccess extends EntrepriseState {}

// final class EntrepriseFailure extends EntrepriseState {
//   final String error;
//   EntrepriseFailure(this.error);
// }

// final class UpdateListUrls extends EntrepriseState {
//   final List<RecentUrl> recentUrls;
//   UpdateListUrls(this.recentUrls);
// }


// class UpdateMethod extends EntrepriseState {
//   final String method;
//   UpdateMethod(this.method);
// }


part of 'entreprise_bloc.dart';

@immutable
sealed class EntrepriseState {}

final class EntrepriseInitial extends EntrepriseState {}



final class EntrepriseLoading extends EntrepriseState {}

final class EntrepriseSuccess extends EntrepriseState {}

final class EntrepriseFailure extends EntrepriseState {
  final String error;
  EntrepriseFailure(this.error);
}

final class UpdateListUrls extends EntrepriseState {
  final List<RecentUrl> recentUrls;
  UpdateListUrls(this.recentUrls);
}