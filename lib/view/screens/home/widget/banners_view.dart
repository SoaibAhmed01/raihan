import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/category_model.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/banner_provider.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannersView extends StatelessWidget {
  const BannersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (context, banner, child) {
        return Container(
          width: MediaQuery.of(context).size.width,
         height: ResponsiveHelper.isDesktop(context) ? 400 : MediaQuery.of(context).size.width * 0.4,
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeSmall),
          child: banner.bannerList != null ? banner.bannerList!.isNotEmpty ? Stack(
            fit: StackFit.expand,
            children: [
              CarouselSlider.builder(
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction:  1,
                  disableCenter: true,
                  onPageChanged: (index, reason) {
                    Provider.of<BannerProvider>(context, listen: false).setCurrentIndex(index);
                  },
                ),
                itemCount: banner.bannerList!.isEmpty ? 1 : banner.bannerList!.length,
                itemBuilder: (context, index, _) {
                  return InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () {
                      if(banner.bannerList![index].productId != null) {
                        Product? product;
                        for(Product prod in banner.productList) {
                          if(prod.id == banner.bannerList![index].productId) {
                            product = prod;
                            break;
                          }
                        }
                        if(product != null) {
                          Navigator.pushNamed(
                            context, RouteHelper.getProductDetailsRoute(productId: product.id),
                          );
                        }

                      }else if(banner.bannerList![index].categoryId != null) {
                        CategoryModel? category;
                        for(CategoryModel categoryModel in Provider.of<CategoryProvider>(context, listen: false).categoryList!) {
                          if(categoryModel.id == banner.bannerList![index].categoryId) {
                            category = categoryModel;
                            break;
                          }
                        }
                        if(category != null) {
                          Navigator.of(context).pushNamed(RouteHelper.getCategoryProductsRouteNew(categoryId: '${category.id}'));
                        }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FadeInImage.assetNetwork(
                          placeholder: Images.getPlaceHolderImage(context),
                          image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls!.bannerImageUrl}'
                              '/${banner.bannerList![index].image}',
                          fit: BoxFit.fitWidth,
                          imageErrorBuilder: (c, o, s) => Image.asset(Images.getPlaceHolderImage(context), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  );
                },
              ),

              Positioned(
                bottom: 5, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: banner.bannerList!.map((bnr) {
                    int index = banner.bannerList!.indexOf(bnr);
                    return TabPageSelectorIndicator(
                      backgroundColor: index == banner.currentIndex ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                      borderColor: index == banner.currentIndex ? Theme.of(context).primaryColor : Theme.of(context).primaryColor,
                      size: 10,
                    );
                  }).toList(),
                ),
              ),
            ],
          ) : Center(child: Text(getTranslated('no_banner_available', context))) : Shimmer(
            duration: const Duration(seconds: 2),
            enabled: banner.bannerList == null,
            child: Container(margin: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            )),
          ),
        );
      },
    );
  }

}
