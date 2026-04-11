import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../domain/entities/location_option.dart';
import '../../domain/weather_state.dart';

class WeatherSearchBar extends StatelessWidget {
  const WeatherSearchBar({
    super.key,
    required this.state,
    required this.colorScheme,
    required this.onQueryChanged,
    required this.onLocationSelected,
  });

  final WeatherState state;
  final ColorScheme colorScheme;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<LocationOption> onLocationSelected;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      begin: const Offset(0, 18),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Autocomplete<LocationOption>(
            displayStringForOption: (option) => option.label,
            optionsBuilder: (textEditingValue) {
              return textEditingValue.text.isEmpty
                  ? const Iterable<LocationOption>.empty()
                  : state.suggestions;
            },
            onSelected: onLocationSelected,
            fieldViewBuilder: (context, controller, focusNode, _) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(fontWeight: FontWeight.w600),
                onChanged: onQueryChanged,
                onTap: () {
                  if (!focusNode.hasFocus) {
                    focusNode.requestFocus();
                  }
                },
                decoration: InputDecoration(
                  hintText: context.tr('search_hint'),
                  hintStyle: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.primary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            controller.clear();
                            onQueryChanged('');
                          },
                        )
                      : null,
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(
                            option.label,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
