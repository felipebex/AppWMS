

import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/constans/gaps.dart';
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';

// ignore: must_be_immutable
class DetailClientSale extends StatefulWidget {
  List listDB;
  DetailClientSale({super.key, required this.listDB});

  @override
  State<DetailClientSale> createState() => _DetailClientSaleState();
}

class _DetailClientSaleState extends State<DetailClientSale> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            // Eliminamos el Positioned y lo ajustamos dentro del Column
            Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(80),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var element in widget.listDB) ...[
                            gapH12,
                            SlideAction(
                              onSubmit: () {
                                Preferences.nameDatabase = element.toString();
                                Navigator.pushNamed(context, 'auth');
                              },
                              text: element,
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              elevation: 0,
                              sliderRotate: false,
                              borderRadius: 20,
                              sliderButtonIcon: const Icon(
                                Icons.lock_open,
                                size: 20,
                                color: primaryColorApp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
