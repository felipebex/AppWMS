import 'package:flutter/material.dart';

final GlobalKey<ScaffoldState> globalKey = GlobalKey();

// Storage and Databases
const String databaseName = 'app_database';

//routes
class AppRoutes {
  //auth routes
  static const splash = '/splash';
  static const politics = '/politics';
  static const company = '/company';
  static const permission = '/permission';
  static const login = '/login';
  static const searchPage = '/search';
  static const codeFormRequest = '/code-form-request';
  static const codeValidation = '/code-validation';
  static const recoverPassword = '/recover-password';
  static const selectEnterprise = '/select-enterprise';

  //home routes
  static const home = '/home';
  static const sync = '/sync';

  //calendar routes
  static const calendar = '/calendar';
  static const createMeet = '/code-create-meet';

  //sales routes
  static const routersSale = '/sale-routers';
  static const clientsSale = '/sale-clients';
  static const filtersSale = '/sale-filters';
  static const productsSale = '/sale-products';
  static const cartSale = '/sale-cart';
  static const historySale = '/sale-history';

  //NAVIGATION ROUTES
  static const navigation = '/navigation';
  static const editStore = '/edit-store-popup';
  static const importStore = '/import-store-popup';
  static const recovery = '/recovery-popup';
  static const downloader = '/downloader-popup';

  //Wallet routes
  static const dashboardWallet = '/wallet-dashboard';
  static const clientsWallet = '/wallet-clients';
  static const summariesWallet = '/wallet-summaries';
  static const notificationWallet = '/wallet-notification';
  static const detailWallet = '/wallet-detail';
  static const manageWallet = '/wallet-manage';
}

// Form Error

final RegExp emailValidatorRegExp =
    RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
const String kEmailNullError = 'Por favor ingresa un correo';
const String kInvalidEmailError = 'Porfavor ingresa un correo válido';
const String kPassNullError = 'Porfavor ingresa una contraseña';
const String kShortPassError = 'La contraseña es demasiado corta';
const String kMatchPassError = 'La contraseña no coindice';
const String kNameNullError = 'Por favor ingresa un nombre';
const String kPhoneNumberNullError = 'Por favor ingresa tu número de telefono';
const String kAddressNullError = 'Por favor ingresa tu dirección';

const String buttonTextDefault = "Permitir";
const String buttonTextSuccess = "Continuar";
const String buttonTextPermanentlyDenied = "Configuración";
const String titleDefault = "Permiso necesario";
const String displayMessageDefault =
    "Para brindarle la mejor experiencia de usuario, necesitamos algunos permisos. Por favor permítelo.";
const String displayMessageSuccess =
    "Éxito, se otorgaron todos los permisos. Por favor, haga clic en el botón de abajo para continuar.";
const String displayMessageDenied =
    "Para brindarle la mejor experiencia de usuario, necesitamos algunos permisos, pero parece que lo negó.";
const String displayMessagePermanentlydenied =
    "Para brindarle la mejor experiencia de usuario, necesitamos algunos permisos, pero parece que lo denegó permanentemente. Vaya a la configuración y actívela manualmente para continuar.";

class Assets {
  //ICONS
  static const String arrowDown = 'assets/icons/arrow_down.png';
  static const String arrowUp = 'assets/icons/arrow_up.png';

  static const String bgPattern = 'assets/images/bg-pattern.png';
  static const String shadow = 'assets/images/shadow.png';
  static const String bexBackgroundWhite =
      'assets/icons/BEX-background-white.png';
  static const String bgSquare = 'assets/images/bg-square.png';

  static const String bgPromCardGreen = "assets/images/bg-prom-card.png";
  static const String bgPromCardOrange = "assets/images/bg-prom-card-2.png";

//STEPPER ICONS
  static const String actionEnable = "assets/icons/actionEnable.png";
  static const String actionDisable = "assets/icons/actionDisable.png";
  static const String invoiceDisable =
      "assets/icons/seleccionarFacturaDisable.png";
  static const String invoiceEnable =
      "assets/icons/seleccionarFacturaEnable.png";
  static const String profileEnable = "assets/icons/ProfileEnable.png";
  static const String profileDisable = "assets/icons/ProfileDisable.png";

  static const String background1 = 'assets/background_1.jpg';
  static const String bank = 'assets/bank.svg';
  static const String coloring = 'assets/coloring.svg';
  static const String cod = 'assets/cod.svg';
  static const String debit = 'assets/debit.svg';
  static const String email = 'assets/email.svg';
  static const String eyeMakeup = 'assets/eye_makeup.svg';
  static const String facebook = 'assets/facebook.svg';
  static const String google = 'assets/google.svg';
  static const String haircut = 'assets/haircut.svg';
  static const String hairstyle = 'assets/hairstyle.svg';
  static const String language = 'assets/language.svg';
  static const String logo = 'assets/logo.svg';
  static const String makeUp = 'assets/make_up.svg';
  static const String map = 'assets/map.png';
  static const String multipleImage = 'assets/multiple_image.svg';
  static const String nails = 'assets/nails.svg';
  static const String offer = 'assets/offer.svg';
  static const String onBoarding1 = 'assets/on_boarding_1.jpg';
  static const String onBoarding2 = 'assets/on_boarding_2.jpg';
  static const String onBoarding3 = 'assets/on_boarding_3.jpg';
  static const String otp = 'assets/otp.svg';
  static const String paypal = 'assets/paypal.svg';
  static const String profilePhoto =
      'https://i.pinimg.com/564x/d3/c0/dc/d3c0dc09efe8a84160c4639003d5f1b5.jpg';
  static const String shampoo = 'assets/shampoo.svg';
  static const String shaving = 'assets/shaving.svg';
  static const String signIn = 'assets/sign_in.jpg';
  static const String spa = 'assets/spa.svg';

  //Wallet Assets
  static const String whatsapp = 'assets/images/wallet/whatsapp.png';
  static const String emailWallet = 'assets/images/wallet/email.png';
  static const String textMessage = 'assets/images/wallet/text-message.png';

  static const String check = 'assets/images/wallet/check.png';
  static const String consignment = 'assets/images/wallet/consignment.png';
  static const String cash = 'assets/images/wallet/cash.png';
  static const String creditNote = 'assets/images/wallet/credit_note.png';
}

class Const {
  static const double elevation = 10;
  static const int splashDuration = 3;
  static const double textFieldRadius = 12;

  static const double buttonRadius = 15;
  static const double padding = 8;
  static const double margin = 18;
  static const double radius = 12;
  static const double space5 = 5;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space15 = 15;
  static const double space18 = 18;
  static const double space25 = 25;
  static const double space40 = 40;
  static const double space50 = 50;
}
