import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_divider.dart';

class OrderAmountView extends StatelessWidget {
  final double itemsPrice;
  final double tax;
  final double subTotal;
  final double discount;
  final double couponDiscount;
  final double deliveryCharge;
  final double total;
  final bool isVatInclude;
  final List<OrderPartialPayment> paymentList;

  const OrderAmountView({
    Key? key, required this.itemsPrice, required this.tax, required this.subTotal,
    required this.discount, required this.couponDiscount, required this.deliveryCharge,
    required this.total, required this.isVatInclude,
    required this.paymentList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('items_price'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

          CustomDirectionality(child: Text(
            PriceConverter.convertPrice(context, itemsPrice),
            style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          )),
        ]),
        const SizedBox(height: 10),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${'tax'.tr} ${isVatInclude ? '(${'include'.tr})' : ''}',
              style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

          CustomDirectionality(child: Text(
            '${isVatInclude ? '' : '(+)'} ${PriceConverter.convertPrice(context, tax)}',
            style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          )),
        ]),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: CustomDivider(color: Theme.of(context).textTheme.bodyLarge!.color),
        ),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('subtotal'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

          CustomDirectionality(child: Text(
            PriceConverter.convertPrice(context, subTotal),
            style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          )),
        ]),
        const SizedBox(height: 10),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('discount'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

          CustomDirectionality(child: Text(
            '(-) ${PriceConverter.convertPrice(context, discount)}',
            style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          )),
        ]),
        const SizedBox(height: 10),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('coupon_discount'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

          Flexible(
            child: CustomDirectionality(child: Text(
              '(-) ${PriceConverter.convertPrice(context, couponDiscount)}',
              style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
            )),
          ),
        ]),
        const SizedBox(height: 10),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('delivery_fee'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

          CustomDirectionality(child: Text(
            '(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
            style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          )),
        ]),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: CustomDivider(),
        ),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('total_amount'.tr, style: poppinsRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor,
          )),

          Flexible(
            child: CustomDirectionality(child: Text(
              PriceConverter.convertPrice(context, total),
              style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
            )),
          ),
        ]),

         if(paymentList.isNotEmpty) Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: DottedBorder(
            dashPattern: const [8, 4],
            strokeWidth: 1.1,
            borderType: BorderType.RRect,
            color: Theme.of(context).primaryColor,
            radius: const Radius.circular(Dimensions.radiusSizeDefault),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.02),
              ),
              padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall, vertical: 1),
              child: Column(children: paymentList.map((payment) => payment.id != null ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Text("${getTranslated(payment.paidAmount! > 0 ? 'paid_amount' : 'due_amount', context)} (${ payment.paidWith != null && payment.paidWith!.isNotEmpty ? '${payment.paidWith?[0].toUpperCase()}${payment.paidWith?.substring(1).replaceAll('_', ' ')}' : getTranslated('${payment.paidWith}', context)})",
                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                    overflow: TextOverflow.ellipsis,),

                  Text(PriceConverter.convertPrice(context, payment.paidAmount! > 0 ? payment.paidAmount : payment.dueAmount),
                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                ],
                ),
              ) : const SizedBox()).toList()),
            ),
          ),
        ),


      ],);
  }
}
