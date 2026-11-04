import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Every icon in the app, by meaning. Backed by Phosphor Icons
/// (phosphor_flutter): regular weight for idle/outline states, fill for
/// active states and small accents, bold where a glyph needs extra weight.
/// Swap an icon app-wide by changing it here.
class AppIcons {
  AppIcons._();

  // ── Bottom navigation (idle / active) ────────────────────────────────────
  static const IconData library = PhosphorIconsRegular.books;
  static const IconData libraryFill = PhosphorIconsFill.books;
  static const IconData discover = PhosphorIconsRegular.compass;
  static const IconData discoverFill = PhosphorIconsFill.compass;
  static const IconData short = PhosphorIconsRegular.bookOpenText;
  static const IconData shortFill = PhosphorIconsFill.bookOpenText;
  static const IconData rank = PhosphorIconsRegular.trophy;
  static const IconData rankFill = PhosphorIconsFill.trophy;
  static const IconData drama = PhosphorIconsRegular.filmSlate;
  static const IconData dramaFill = PhosphorIconsFill.filmSlate;
  static const IconData popcorn = PhosphorIconsFill.popcorn;
  static const IconData user = PhosphorIconsRegular.user;
  static const IconData userFill = PhosphorIconsFill.user;

  // ── Navigation & actions ─────────────────────────────────────────────────
  static const IconData back = PhosphorIconsRegular.caretLeft;
  static const IconData arrowLeft = PhosphorIconsRegular.arrowLeft;
  static const IconData arrowRight = PhosphorIconsBold.arrowRight;
  static const IconData chevronRight = PhosphorIconsRegular.caretRight;
  static const IconData caretUp = PhosphorIconsRegular.caretUp;
  static const IconData caretDown = PhosphorIconsRegular.caretDown;
  static const IconData readMore = PhosphorIconsRegular.caretDoubleDown;
  static const IconData close = PhosphorIconsRegular.x;
  static const IconData clearFill = PhosphorIconsFill.xCircle;
  static const IconData check = PhosphorIconsBold.check;
  static const IconData checkCircleFill = PhosphorIconsFill.checkCircle;
  static const IconData add = PhosphorIconsRegular.plus;
  static const IconData dash = PhosphorIconsRegular.minus;
  static const IconData more = PhosphorIconsRegular.dotsThree;
  static const IconData search = PhosphorIconsRegular.magnifyingGlass;
  static const IconData searchOff = PhosphorIconsRegular.magnifyingGlassMinus;
  static const IconData filterOff = PhosphorIconsRegular.funnelSimpleX;
  static const IconData categories = PhosphorIconsFill.squaresFour;
  static const IconData list = PhosphorIconsRegular.listBullets;
  static const IconData send = PhosphorIconsFill.paperPlaneTilt;
  static const IconData share = PhosphorIconsRegular.shareNetwork;
  static const IconData delete = PhosphorIconsRegular.trash;
  static const IconData flag = PhosphorIconsRegular.flag;
  static const IconData block = PhosphorIconsRegular.prohibit;
  static const IconData help = PhosphorIconsRegular.question;
  static const IconData info = PhosphorIconsRegular.info;
  static const IconData eye = PhosphorIconsRegular.eye;
  static const IconData eyeOff = PhosphorIconsRegular.eyeSlash;
  static const IconData radioOn = PhosphorIconsFill.radioButton;
  static const IconData radioOff = PhosphorIconsRegular.circle;
  static const IconData autoRenew = PhosphorIconsRegular.arrowsClockwise;
  static const IconData exchange = PhosphorIconsRegular.arrowsLeftRight;

  // ── Reading ──────────────────────────────────────────────────────────────
  static const IconData book = PhosphorIconsRegular.bookOpen;
  static const IconData libraryAdd = PhosphorIconsRegular.bookmarkSimple;
  static const IconData libraryAdded = PhosphorIconsFill.bookmarkSimple;
  static const IconData history = PhosphorIconsRegular.clockCounterClockwise;
  static const IconData lock = PhosphorIconsRegular.lockSimple;
  static const IconData lockFill = PhosphorIconsFill.lockSimple;
  static const IconData lockOpen = PhosphorIconsRegular.lockSimpleOpen;
  static const IconData textSettings = PhosphorIconsRegular.textAa;
  static const IconData textSmaller = PhosphorIconsRegular.minusCircle;
  static const IconData textBigger = PhosphorIconsRegular.plusCircle;
  static const IconData sun = PhosphorIconsRegular.sun;
  static const IconData moon = PhosphorIconsRegular.moon;
  static const IconData write = PhosphorIconsRegular.pencilSimpleLine;
  static const IconData explore = PhosphorIconsRegular.compass;

  // ── Ratings & social ─────────────────────────────────────────────────────
  static const IconData star = PhosphorIconsRegular.star;
  static const IconData starFill = PhosphorIconsFill.star;
  static const IconData starHalf = PhosphorIconsFill.starHalf;
  static const IconData heart = PhosphorIconsRegular.heart;
  static const IconData heartFill = PhosphorIconsFill.heart;
  static const IconData fire = PhosphorIconsFill.fire;
  static const IconData userAdd = PhosphorIconsRegular.userPlus;
  static const IconData handHeart = PhosphorIconsRegular.handHeart;
  static const IconData female = PhosphorIconsFill.genderFemale;
  static const IconData male = PhosphorIconsFill.genderMale;

  // ── Money & rewards ──────────────────────────────────────────────────────
  static const IconData coin = PhosphorIconsFill.coin;
  static const IconData bonus = PhosphorIconsFill.sparkle;
  static const IconData diamond = PhosphorIconsRegular.diamond;
  static const IconData diamondFill = PhosphorIconsFill.diamond;
  static const IconData wallet = PhosphorIconsFill.wallet;
  static const IconData payments = PhosphorIconsRegular.coins;
  static const IconData gift = PhosphorIconsFill.gift;
  static const IconData redeem = PhosphorIconsRegular.gift;
  static const IconData ticket = PhosphorIconsRegular.ticket;
  static const IconData voucher = PhosphorIconsFill.ticket;
  static const IconData receipt = PhosphorIconsRegular.receipt;
  static const IconData play = PhosphorIconsRegular.playCircle;
  static const IconData playFill = PhosphorIconsFill.play;
  static const IconData pauseFill = PhosphorIconsFill.pause;
  static const IconData video = PhosphorIconsFill.videoCamera;
  static const IconData episodes = PhosphorIconsFill.squaresFour;
  static const IconData skipNext = PhosphorIconsFill.skipForward;
  static const IconData calendarCheck = PhosphorIconsRegular.calendarCheck;
  static const IconData insights = PhosphorIconsRegular.chartLineUp;
  static const IconData megaphone = PhosphorIconsRegular.megaphone;

  // ── Account & support ────────────────────────────────────────────────────
  static const IconData mail = PhosphorIconsRegular.envelopeSimple;
  static const IconData mailUnread = PhosphorIconsRegular.envelopeSimpleOpen;
  static const IconData bell = PhosphorIconsFill.bell;
  static const IconData settings = PhosphorIconsRegular.gear;
  static const IconData headset = PhosphorIconsRegular.headset;
  static const IconData agent = PhosphorIconsFill.headset;

  // ── Author Center ────────────────────────────────────────────────────────
  static const IconData addCircle = PhosphorIconsFill.plusCircle;
  static const IconData calendar = PhosphorIconsRegular.calendarBlank;
  static const IconData calendarFill = PhosphorIconsFill.calendarBlank;
  static const IconData chat = PhosphorIconsRegular.chatCircleDots;
  static const IconData chatFill = PhosphorIconsFill.chatCircleDots;
  static const IconData income = PhosphorIconsRegular.wallet;
  static const IconData stats = PhosphorIconsFill.chartBar;
  static const IconData image = PhosphorIconsRegular.image;
  static const IconData upload = PhosphorIconsRegular.uploadSimple;
  static const IconData edit = PhosphorIconsRegular.pencilSimple;
  static const IconData restore = PhosphorIconsRegular.arrowCounterClockwise;
  static const IconData medal = PhosphorIconsFill.medal;
  static const IconData lightbulb = PhosphorIconsRegular.lightbulb;

  // ── Brands ───────────────────────────────────────────────────────────────
  static const IconData facebook = PhosphorIconsFill.facebookLogo;
  static const IconData google = PhosphorIconsBold.googleLogo;
  static const IconData apple = PhosphorIconsFill.appleLogo;
  static const IconData tiktok = PhosphorIconsFill.tiktokLogo;
  static const IconData instagram = PhosphorIconsFill.instagramLogo;
}
