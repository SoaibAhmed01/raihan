import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/cart_model.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/screens/order/widget/re_order_dialog.dart';
import 'package:provider/provider.dart';

import '../order_details_screen.dart';
class OrderCard extends StatelessWidget {
  const OrderCard({Key? key, required this.orderList, required this.index}) : super(key: key);

  final List<OrderModel>? orderList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(
          color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 300]!,
          spreadRadius: 1, blurRadius: 5,
        )],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //date and money
        Row(children: [
          Text(
            DateConverter.isoDayWithDateString(orderList![index].updatedAt!),
            style: poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
          ),
          const Expanded(child: SizedBox.shrink()),

          CustomDirectionality(child: Text(
            PriceConverter.convertPrice(context, orderList![index].orderAmount),
            style: poppinsBold.copyWith(color: Theme.of(context).primaryColor),
          )),
        ]),
        const SizedBox(height: 8),
        //Order list
        Text('${getTranslated('order_id', context)} #${orderList![index].id.toString()}', style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        //item position
        Row(children: [
          Icon(Icons.circle, color: Theme.of(context).primaryColor, size: 16),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(
            '${getTranslated('order_is', context)} ${getTranslated(orderList![index].orderStatus, context)}',
            style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        SizedBox(
          height: 50,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // View Details Button
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(
                  RouteHelper.getOrderDetailsRoute('${orderList![index].id}'),
                  arguments: OrderDetailsScreen(orderId: orderList![index].id, orderModel: orderList![index]),
                );
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: ColorResources.getGreyColor(context),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 100]!,
                          spreadRadius: 1,
                          blurRadius: 5)
                    ],
                    borderRadius: BorderRadius.circular(10)),
                child: Text(getTranslated('view_details', context),
                    style: poppinsRegular.copyWith(
                      color: Colors.black,
                      fontSize: Dimensions.fontSizeDefault,
                    )),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            orderList![index].orderType != 'pos' ? Consumer<ProductProvider>(builder: (context, productProvider, _)=> Consumer<OrderProvider>(builder: (context, orderProvider, _) {
              bool isReOrderAvailable = orderProvider.getReOrderIndex == null || (orderProvider.getReOrderIndex != null &&  productProvider.product != null);

              return (orderProvider.isLoading || productProvider.product == null) && index == orderProvider.getReOrderIndex && !orderProvider.isActiveOrder ? CustomLoader(color: Theme.of(context).primaryColor) : TextButton(
                style: TextButton.styleFrom(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  side: BorderSide(width: 2, color: !orderProvider.isLoading && isReOrderAvailable ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                )),
                onPressed: () async {
                  if(orderProvider.isActiveOrder) {
                    Navigator.of(context).pushNamed(RouteHelper.getOrderTrackingRoute(orderList![index].id, null));
                  }else {
                    if(!orderProvider.isLoading && isReOrderAvailable) {
                      orderProvider.setReorderIndex = index;
                      List<CartModel>? cartList =  await orderProvider.reorderProduct('${orderList![index].id}');
                      if(context.mounted && cartList != null &&  cartList.isNotEmpty){
                        showDialog(context: context, builder: (context)=> const ReOrderDialog());
                      }
                    }
                  }
                },
                child: Text(
                  getTranslated( orderProvider.isActiveOrder ? 'track_your_order' : 're_order' , context),
                  style: poppinsRegular.copyWith(
                    color: !orderProvider.isLoading && isReOrderAvailable ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              );

            })
            ) : const SizedBox.shrink(),


            //Track your Order Button
          ]),
        ),
      ]),
    );
  }
}
