import 'dart:io';

import 'package:colo/model/account.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:colo/widgets/blur.dart';
import 'package:colo/widgets/button.dart';
import 'package:colo/widgets/load.dart';
import 'package:colo/widgets/shadow.dart';
import 'package:colo/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// --------------------- Products ---------------------------------------------
const _productPremium = 'premium';
const _productDifficulty = 'difficulty_select';
const _productNoAds = 'game_ads';
const _productRocketLimiter = 'rocket_limiter';
/// ----------------------------------------------------------------------------

/// Renders the game store overlay
class GameStoreDialog extends HookConsumerWidget {

  /// User account
  final Account account;

  const GameStoreDialog({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = InAppPurchase.instance;

    /// Render btn for restoring purchases
    Widget renderRestorePurchasesBtn() => ShadowWidget(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await InAppPurchase.instance.restorePurchases();
              ref.read(overlayVisibilityProvider(const Key('game_store')).notifier).setOverlayVisibility(false);
            },
            child: const Card(
              color: Colors.black,
              child: SizedBox(
                width: 300,
                child: StyledText(
                  text: 'Restore purchases',
                  fontSize: 18,
                  align: TextAlign.center,
                  clip: false,
                  letterSpacing: 2,
                  color: Colors.red,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
    );

    return FutureBuilder<bool>(
        future: purchases.isAvailable(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: LoadingIndicator(color: Colors.purple)
            );
          }

          if (snapshot.data! == false) {
            return Center(
                child: StyledText(
                  text: 'There are no upgrades at this time',
                  fontSize: 14,
                  align: TextAlign.start,
                  letterSpacing: 2,
                  gradientColors: List.generate(barColors.values.length, (index) {
                    final color = barColors.values.toList()[index];

                    return Color.fromRGBO(color.red, color.green, color.blue, 0.6);
                  }),
                  weight: FontWeight.bold,
                  useShadow: true,
                )
            );
          } else {
            /// Generates the in app purchases
            Set<String> formProductIds() {
              final List<String> productIds = [];
              if (account.noAds != true || account.rocketLimiter != true || account.difficultySelect != true) {
                productIds.add(_productPremium);
              }
              if (account.difficultySelect != true) {
                productIds.add(_productDifficulty);
              }
              if (account.noAds != true) {
                productIds.add(_productNoAds);
              }
              if (account.rocketLimiter != true) {
                productIds.add(_productRocketLimiter);
              }

              return productIds.toSet();
            }

            return FutureBuilder<ProductDetailsResponse>(
                future: purchases.queryProductDetails(formProductIds()),
                builder: (context, details) {
                  String? error;
                  if (!snapshot.hasData) {

                    return const Center(
                        child: LoadingIndicator(color: Colors.purple)
                    );
                  }

                  if (details.data == null) {
                    return const Center(
                        child: LoadingIndicator(color: Colors.purple)
                    );
                  }
                  /// Available products to sell
                  final List<ProductDetails> products = details.data!.productDetails;

                  if (details.data!.error != null) {
                    error = 'No connection with the store';
                  } else if (products.isEmpty) {
                    error = 'Store is empty';
                  }

                  if (error != null) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadowWidget(
                          child: Container(
                            color: Colors.black54,
                            width: double.infinity,
                            child: StyledText(
                              text: error,
                              fontSize: 25,
                              clip: false,
                              align: TextAlign.center,
                              letterSpacing: 2,
                              gradientColors: barColors.values.toList(),
                              weight: FontWeight.bold,
                              useShadow: true,
                            ),
                          ),
                        ),
                        renderRestorePurchasesBtn()
                      ],
                    );
                  }
                  return _GameStoreBody(products: products, renderRestorePurchases: renderRestorePurchasesBtn());
                }
            );
          }
        });
  }
}

/// Renders the game store dialog body
class _GameStoreBody extends HookConsumerWidget {
  /// Available products for sale
  final List<ProductDetails> products;

  final Widget renderRestorePurchases;

  const _GameStoreBody({required this.products, required this.renderRestorePurchases});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool? shouldShowGameStoreDialog = ref.watch(overlayVisibilityProvider(const Key('game_store')));
    final body = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(),
              DefaultButton(
                  onClick: () => ref.read(overlayVisibilityProvider(const Key('game_store')).notifier).setOverlayVisibility(false),
                  color: Colors.black,
                  svgColor: Colors.pink.withOpacity(0.5),
                  borderColor: Colors.black,
                  icon: 'assets/svgs/close.svg'
              ),
            ],
          ),
          ...products.map((product) {
            late PurchaseParam purchaseParam;
            if (Platform.isAndroid) {
              purchaseParam = GooglePlayPurchaseParam(productDetails: product);
            } else {
              purchaseParam = PurchaseParam(productDetails: product);
            }
            return ShadowWidget(
              child: Card(
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: NormalButton(
                          color: Colors.pink.withOpacity(0.3),
                          text: StyledText(
                            family: 'RenegadePursuit',
                            gradientColors: barColors.values.toList(),
                            text: product.price,
                            fontSize: 13,
                            align: TextAlign.start,
                            color: Colors.white,
                            weight: FontWeight.bold,
                          ),
                          onClick: () async {
                            if (product.id == _productPremium) {
                              ref.read(overlayVisibilityProvider(const Key('game_store')).notifier).setOverlayVisibility(false);
                            }
                            await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
                          }
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StyledText(
                            text: product.title,
                            fontSize: 18,
                            align: TextAlign.start,
                            clip: false,
                            maxLines: 4,
                            letterSpacing: 2,
                            gradientColors: barColors.values.toList(),
                            weight: FontWeight.bold,
                          ),
                          StyledText(
                            text: product.description,
                            fontSize: 12,
                            clip: false,
                            maxLines: 4,
                            padding: const EdgeInsets.only(left: 15, bottom: 15),
                            align: TextAlign.start,
                            letterSpacing: 2,
                            gradientColors: barColors.values.toList(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          renderRestorePurchases,
          const SizedBox(height: 10,)
        ],
      ),
    );

    return shouldShowGameStoreDialog != null && shouldShowGameStoreDialog ? Blurrable(
      strength: 5,
      child: body,
    ) : body;
  }
}