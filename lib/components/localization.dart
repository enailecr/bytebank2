import 'dart:async';
import 'package:bytebank2/components/error.dart';
import 'package:bytebank2/components/progress.dart';
import 'package:bytebank2/http/webclients/i18n_webclient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localstorage/localstorage.dart';

import 'container.dart';

class LocalizationContainer extends BlocContainer {
  final Widget child;

  LocalizationContainer({required Widget this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CurrentLocalCubit>(
      create: (context) => CurrentLocalCubit(),
      child: this.child,
    );
  }
}

class CurrentLocalCubit extends Cubit<String> {
  CurrentLocalCubit() : super('en');
}

class ViewI18N {
  String _language = '';

  ViewI18N(BuildContext context) {
    this._language = BlocProvider.of<CurrentLocalCubit>(context).state;
  }

  String localize(Map<String, String> map) {
    assert(map != null);
    assert(map.containsKey(_language));
    return map[_language].toString();
  }
}

@immutable
abstract class I18NMEssagesState {
  const I18NMEssagesState();
}

@immutable
class LoadingI18NMEssagesState extends I18NMEssagesState {
  const LoadingI18NMEssagesState();
}

@immutable
class InitI18NMEssagesState extends I18NMEssagesState {
  const InitI18NMEssagesState();
}

@immutable
class LoadedI18NMEssagesState extends I18NMEssagesState {
  final I18NMessages _messages;
  const LoadedI18NMEssagesState(this._messages);
}

class I18NMessages {
  final Map<String, dynamic> _messages;
  I18NMessages(this._messages);

  String get(String key) {
    assert(key != null);
    assert(_messages.containsKey(key));
    return _messages[key].toString();
  }
}

@immutable
class FatalErrorI18NMEssagesState extends I18NMEssagesState {
  const FatalErrorI18NMEssagesState();
}

typedef Widget I18WidgetCreator(I18NMessages messages);

class I18NLoadingContainer extends BlocContainer {
  late I18WidgetCreator creator;
  String? viewKey;

  I18NLoadingContainer(
      {required String? viewKey, required I18WidgetCreator creator}) {
    this.creator = creator;
    this.viewKey = viewKey;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<I18NMessagesCubit>(
      create: (BuildContext context) {
        final cubit = I18NMessagesCubit(this.viewKey);
        cubit.reload(I18NWebClient(this.viewKey));
        return cubit;
      },
      child: I18NLoadingView(this.creator),
    );
  }
}

class I18NLoadingView extends StatelessWidget {
  final I18WidgetCreator _creator;
  I18NLoadingView(this._creator);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<I18NMessagesCubit, I18NMEssagesState>(
      builder: (context, state) {
        if (state is InitI18NMEssagesState ||
            state is LoadingI18NMEssagesState) {
          return ProgressView(message: "Loading...");
        }
        if (state is LoadedI18NMEssagesState) {
          final messages = state._messages;
          return _creator.call(messages);
        }
        return ErrorView('Erro buscando');
      },
    );
  }
}

class I18NMessagesCubit extends Cubit<I18NMEssagesState> {
  final LocalStorage storage = new LocalStorage('local_insecure_v1.json');
  final String? _viewKey;
  I18NMessagesCubit(this._viewKey) : super(InitI18NMEssagesState());

  reload(I18NWebClient client) async {
    emit(LoadingI18NMEssagesState());
    await storage.ready;
    final items = storage.getItem(_viewKey.toString());
    print("Loaded $_viewKey $items");
    if (items != null) {
      emit(LoadedI18NMEssagesState(I18NMessages(items)));
      return;
    }

    client.findAll().then((messages) => saveAndRefresh(I18NMessages(messages)));

    // emit(LoadedI18NMEssagesState(I18NMessages({
    //   "transfer": "TRANSFER",
    //   "transaction_feed": "TRANSACTION FEED",
    //   "change_name": "CHANGE NAME"
    // })));
  }

  saveAndRefresh(I18NMessages messages) {
    print("salvando");
    storage.setItem(_viewKey.toString(), messages);
    final state = LoadedI18NMEssagesState(messages);
    emit(state);
    print("salvo");
  }
}
