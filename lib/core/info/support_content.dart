import 'package:flutter/material.dart';

class SupportContent {
  static const String guidelinesTitle = "Guidelines";
  static const String guidelinesBody =
      "1. All grievances must be submitted via the portal.\n"
      "2. Expect a response within 48-72 working hours.\n"
      "3. Keep your ID and evidence ready for faster resolution.";

  static const String ugcTitle = "UGC Information";
  static const String ugcBody =
      "University Grants Commission (UGC) mandates every institution to have a functional Grievance Redressal Committee (GRC) as per the 2023 regulations.";

  static const String termsTitle = "Terms & Policy";
  static const String termsBody =
      "By using this portal, you agree that all information provided is true.\nMisleading information may lead to disciplinary action.";

  static const String helpTitle = "Help & Support";
  static const String helpBody =
      "Technical issue? \nEmail us at support@kcg.edu or \nvisit the IT department between \n9:00 AM and 4:00 PM.";

  /// Data mapping for the UI
  static List<Map<String, dynamic>> get data => [
    {
      "title": guidelinesTitle,
      "icon": Icons.description_outlined,
      "content": guidelinesBody,
    },
    {
      "title": ugcTitle,
      "icon": Icons.info_outline,
      "content": ugcBody,
    },
    {
      "title": termsTitle,
      "icon": Icons.verified_user_outlined,
      "content": termsBody,
    },
    {
      "title": helpTitle,
      "icon": Icons.help_outline_rounded,
      "content": helpBody,
    },
  ];
}