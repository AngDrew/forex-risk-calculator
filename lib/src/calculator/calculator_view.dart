import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'calculator.dart';

class CalculatorView extends ConsumerStatefulWidget {
  const CalculatorView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends ConsumerState<CalculatorView> {
  final OutlineInputBorder _textFieldBorder =
      OutlineInputBorder(borderRadius: BorderRadius.circular(16.0));

  @override
  Widget build(BuildContext context) {
    final stateWatcher = ref.watch(calculatorViewModel);

    return LayoutBuilder(
      builder: (_, constraints) {
        int flexSize = 3;
        if (constraints.maxWidth < 600) {
          flexSize = 1;
        }

        return GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Scaffold(
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: stateWatcher.tabLength(),
                            separatorBuilder: (_, index) => const VerticalDivider(width: 16.0),
                            itemBuilder: (_, index) {
                              Widget child =
                                  Text('Basis ${stateWatcher.getDataOf(index)?.basis ?? '-'}');

                              return Row(
                                children: <Widget>[
                                  ChoiceChip(
                                    label: child,
                                    onSelected: (value) {
                                      stateWatcher.switchTabTo(index);
                                    },
                                    selected: index == stateWatcher.currentTabIndex,
                                    showCheckmark: false,
                                  ),
                                  const SizedBox(width: 4.0),
                                  InkWell(
                                    onDoubleTap: () {
                                      stateWatcher.deleteAt(index);
                                    },
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Double tap to delete'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.close_rounded, size: 20.0),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      NewTabButton(stateWatcher: stateWatcher),
                      DeleteTabsButton(stateWatcher: stateWatcher),
                      const InfoButton(),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  CapitalRiskAndBasis(
                    textFieldBorder: _textFieldBorder,
                    stateWatcher: stateWatcher,
                  ),
                  const SizedBox(height: 16.0),
                  EntryPriceAndOrderSwitch(
                    textFieldBorder: _textFieldBorder,
                    flexSize: flexSize,
                    stateWatcher: stateWatcher,
                  ),
                  const SizedBox(height: 16.0),
                  // TP/SL with pips
                  SlAndTpByPips(
                    stateWatcher: stateWatcher,
                    textFieldBorder: _textFieldBorder,
                  ),
                  // TP/SL with price
                  const SizedBox(height: 16.0),
                  SlAndTpByPrice(
                    stateWatcher: stateWatcher,
                    textFieldBorder: _textFieldBorder,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: stateWatcher.calculate,
                    child: const Text('Calculate'),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Lot Size: ${stateWatcher.lot}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Loss on SL: \$${stateWatcher.lossOnSL}',
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.deepOrange),
                  ),
                  Text(
                    'Profit on TP: \$${stateWatcher.profitOnTP}',
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.lightGreen),
                  ),
                  Text(
                    'RRR: 1 : ${stateWatcher.rrr}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
