import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/models/staff_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/staff_controller.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/drag_detector.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/layouts/connections_grid.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/top_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class StaffView extends StatelessWidget {
  final int id;
  final String? imageUrl;

  StaffView(this.id, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final axis = MediaQuery.of(context).size.width > 450
        ? Axis.horizontal
        : Axis.vertical;
    double coverWidth = MediaQuery.of(context).size.width * 0.35;
    if (coverWidth > 200) coverWidth = 200;
    final coverHeight = coverWidth / 0.7;

    final offset = (axis == Axis.vertical ? coverHeight * 2 : coverHeight) +
        Consts.PADDING.top * 2;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GetBuilder<StaffController>(
          init: StaffController(id),
          tag: id.toString(),
          builder: (ctrl) => DragDetector(
            onSwipe: (goRight) {
              if (goRight) {
                if (ctrl.onCharacters) ctrl.onCharacters = false;
              } else {
                if (!ctrl.onCharacters) ctrl.onCharacters = true;
              }
            },
            child: CustomScrollView(
              physics: Consts.PHYSICS,
              controller: ctrl.scrollCtrl,
              slivers: [
                GetBuilder<StaffController>(
                  id: StaffController.ID_MAIN,
                  tag: id.toString(),
                  builder: (s) => TopSliverHeader(
                    toggleFavourite: s.toggleFavourite,
                    isFavourite: s.model?.isFavourite,
                    favourites: s.model?.favourites,
                    text: s.model?.name,
                  ),
                ),
                GetBuilder<StaffController>(
                  id: StaffController.ID_MAIN,
                  tag: id.toString(),
                  builder: (s) => SliverPadding(
                    padding: Consts.PADDING,
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: axis == Axis.horizontal
                            ? coverHeight
                            : coverHeight * 2,
                        child: Flex(
                          direction: axis,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (imageUrl != null)
                              GestureDetector(
                                child: Hero(
                                  tag: s.id,
                                  child: ClipRRect(
                                    borderRadius: Consts.BORDER_RADIUS,
                                    child: Image.network(
                                      imageUrl!,
                                      fit: BoxFit.cover,
                                      width: coverWidth,
                                      height: coverHeight,
                                    ),
                                  ),
                                ),
                                onTap: () =>
                                    showPopUp(context, ImageDialog(imageUrl!)),
                              ),
                            const SizedBox(height: 10, width: 10),
                            if (s.model != null) _Details(ctrl.model!, axis),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverShadowAppBar([
                  GetBuilder<StaffController>(
                    id: StaffController.ID_MEDIA,
                    tag: id.toString(),
                    builder: (ctrl) {
                      return BubbleTabs(
                        items: const {'Characters': true, 'Staff Roles': false},
                        current: () => ctrl.onCharacters,
                        onChanged: (bool value) {
                          ctrl.onCharacters = value;
                          ctrl.scrollUpTo(offset);
                        },
                        onSame: () => ctrl.scrollUpTo(offset),
                      );
                    },
                  ),
                  const Spacer(),
                  AppBarIcon(
                    tooltip: 'Filter',
                    icon: Ionicons.funnel_outline,
                    onTap: () => DragSheet.show(
                      context,
                      OptionDragSheet(
                        options: const ['Everything', 'On List', 'Not On List'],
                        index: ctrl.onList == null
                            ? 0
                            : ctrl.onList!
                                ? 1
                                : 2,
                        onTap: (val) => ctrl.onList = val == 0
                            ? null
                            : val == 1
                                ? true
                                : false,
                      ),
                    ),
                  ),
                  AppBarIcon(
                    tooltip: 'Sort',
                    icon: Ionicons.filter_outline,
                    onTap: () => Sheet.show(
                      ctx: context,
                      sheet: MediaSortSheet(ctrl.sort, (s) => ctrl.sort = s),
                    ),
                  ),
                ]),
                GetBuilder<StaffController>(
                  id: StaffController.ID_MEDIA,
                  tag: id.toString(),
                  builder: (ctrl) {
                    final connections =
                        ctrl.onCharacters ? ctrl.characters : ctrl.roles;

                    if (connections.isEmpty)
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'No resuts',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      );

                    return SliverPadding(
                      padding: EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                        bottom: MediaQuery.of(context).viewPadding.bottom + 10,
                      ),
                      sliver: ConnectionsGrid(connections: connections),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final StaffModel model;
  final Axis axis;
  _Details(this.model, this.axis);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => Toast.copy(context, model.name),
            child: Text(
              model.name,
              style: Theme.of(context).textTheme.headline1,
              textAlign: axis == Axis.vertical ? TextAlign.center : null,
            ),
          ),
          Text(
            model.altNames.join(', '),
            textAlign: axis == Axis.vertical ? TextAlign.center : null,
          ),
          const SizedBox(height: 10),
          if (model.description.isNotEmpty)
            Expanded(
              child: InputFieldStructure(
                title: 'Description',
                child: Expanded(
                  child: GestureDetector(
                    child: Container(
                      padding: Consts.PADDING,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: Consts.BORDER_RADIUS,
                      ),
                      child: Text(
                        Convert.clearHtml(model.description),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    onTap: () => showPopUp(
                      context,
                      HtmlDialog(title: 'Description', text: model.description),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
