import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stream_chat/stream_chat.dart';
import 'package:stream_chat_flutter/src/info_tile.dart';
import 'package:stream_chat_flutter/src/message_search_item.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../stream_chat_flutter.dart';

/// Callback called when tapping on a user
typedef MessageSearchItemTapCallback = void Function(GetMessageResponse);

/// Builder used to create a custom [ListUserItem] from a [User]
typedef MessageSearchItemBuilder = Widget Function(
    BuildContext, GetMessageResponse);

/// Builder used when [MessageSearchListView] is empty
typedef EmptyMessageSearchBuilder = Widget Function(
    BuildContext context, String searchQuery);

///
/// It shows the list of searched messages.
///
/// ```dart
/// class MessageSearchPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: MessageSearchListView(
///               messageQuery: _channelQuery,
///               filters: {
///                 'members': {
///                   r'$in': [user.id]
///                 }
///               },
///               paginationParams: PaginationParams(limit: 20),
///       ),
///     );
///   }
/// }
/// ```
///
///
/// Make sure to have a [MessageSearchBloc] ancestor in order to provide the information about the messages.
/// The widget uses a [ListView.separated] to render the list of messages.
///
/// The widget components render the ui based on the first ancestor of type [StreamChatTheme].
/// Modify it to change the widget appearance.
class MessageSearchListView extends StatefulWidget {
  /// Instantiate a new MessageSearchListView
  const MessageSearchListView({
    Key key,
    this.messageQuery,
    this.filters,
    this.sortOptions,
    this.paginationParams,
    this.messageFilters,
    this.emptyBuilder,
    this.errorBuilder,
    this.separatorBuilder,
    this.itemBuilder,
    this.onItemTap,
    this.showResultCount = true,
    this.pullToRefresh = true,
    this.showErrorTile = false,
  }) : super(key: key);

  /// Message String to search on
  final String messageQuery;

  /// The query filters to use.
  /// You can query on any of the custom fields you've defined on the [Channel].
  /// You can also filter other built-in channel fields.
  final Map<String, dynamic> filters;

  /// The sorting used for the channels matching the filters.
  /// Sorting is based on field and direction, multiple sorting options can be provided.
  /// You can sort based on last_updated, last_message_at, updated_at, created_at or member_count.
  /// Direction can be ascending or descending.
  final List<SortOption> sortOptions;

  /// Pagination parameters
  /// limit: the number of users to return (max is 30)
  /// offset: the offset (max is 1000)
  /// message_limit: how many messages should be included to each channel
  final PaginationParams paginationParams;

  /// The message query filters to use.
  /// You can query on any of the custom fields you've defined on the [Channel].
  /// You can also filter other built-in channel fields.
  final Map<String, dynamic> messageFilters;

  /// Builder used to create a custom item preview
  final MessageSearchItemBuilder itemBuilder;

  /// Function called when tapping on a [MessageSearchItem]
  final MessageSearchItemTapCallback onItemTap;

  /// The builder used when the channel list is empty.
  final EmptyMessageSearchBuilder emptyBuilder;

  /// The builder that will be used in case of error
  final Widget Function(Error error) errorBuilder;

  /// Builder used to create a custom item separator
  final IndexedWidgetBuilder separatorBuilder;

  /// Set it to false to hide total results text
  final bool showResultCount;

  /// Set it to false to disable the pull-to-refresh widget
  final bool pullToRefresh;

  final bool showErrorTile;

  @override
  _MessageSearchListViewState createState() => _MessageSearchListViewState();
}

class _MessageSearchListViewState extends State<MessageSearchListView> {
  @override
  void initState() {
    super.initState();
    final messageSearchBloc = MessageSearchBloc.of(context);
    messageSearchBloc.search(
      filter: widget.filters,
      sort: widget.sortOptions,
      query: widget.messageQuery,
      pagination: widget.paginationParams,
      messageFilter: widget.messageFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageSearchBloc = MessageSearchBloc.of(context);
    return _buildListView(messageSearchBloc);
  }

  Widget _separatorBuilder(BuildContext context, int index) {
    return Container(
      height: 1,
      color: StreamChatTheme.of(context).colorTheme.greyWhisper,
    );
  }

  Widget _listItemBuilder(
      BuildContext context, GetMessageResponse getMessageResponse) {
    if (widget.itemBuilder != null) {
      return widget.itemBuilder(context, getMessageResponse);
    }
    return MessageSearchItem(
      getMessageResponse: getMessageResponse,
      onTap: () => widget.onItemTap(getMessageResponse),
    );
  }

  Widget _buildQueryProgressIndicator(
      context, MessageSearchBlocState messageSearchBloc) {
    return StreamBuilder<bool>(
        stream: messageSearchBloc.queryMessagesLoading,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .accentRed
                  .withOpacity(.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text('Error loading messages'),
                ),
              ),
            );
          }
          return Container(
            height: 100,
            padding: EdgeInsets.all(32),
            child: Center(
              child: snapshot.data ? CircularProgressIndicator() : Container(),
            ),
          );
        });
  }

  Widget _buildListView(MessageSearchBlocState messageSearchBloc) {
    return StreamBuilder<List<GetMessageResponse>>(
      stream: messageSearchBloc.messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error is Error) {
            print((snapshot.error as Error).stackTrace);
          }

          if (widget.errorBuilder != null) {
            return widget.errorBuilder(snapshot.error);
          }

          var message = snapshot.error.toString();
          if (snapshot.error is DioError) {
            final dioError = snapshot.error as DioError;
            if (dioError.type == DioErrorType.RESPONSE) {
              message = dioError.message;
            } else {
              message = 'Check your connection and retry';
            }
          }
          return InfoTile(
            showMessage: widget.showErrorTile,
            tileAnchor: Alignment.topCenter,
            childAnchor: Alignment.topCenter,
            message: 'An error occurred.',
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Icon(Icons.error_outline),
                          ),
                        ),
                        TextSpan(text: 'Error loading messages'),
                      ],
                    ),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(message),
                  ),
                  RaisedButton(
                    onPressed: () {
                      messageSearchBloc.search(
                        filter: widget.filters,
                        sort: widget.sortOptions,
                        query: widget.messageQuery,
                        pagination: widget.paginationParams,
                        messageFilter: widget.messageFilters,
                      );
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return LayoutBuilder(
            builder: (context, viewportConstraints) {
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            },
          );
        }

        final items = snapshot.data;

        if (items.isEmpty) {
          if (widget.emptyBuilder != null) {
            return widget.emptyBuilder(context, widget.messageQuery);
          }
          return LayoutBuilder(
            builder: (context, viewportConstraints) {
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Center(
                    child: Text('There are no messages currently'),
                  ),
                ),
              );
            },
          );
        }

        Widget child = ListView.separated(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: items.isNotEmpty ? items.length + 1 : items.length,
          separatorBuilder: (_, index) {
            if (widget.separatorBuilder != null) {
              return widget.separatorBuilder(context, index);
            }
            return _separatorBuilder(context, index);
          },
          itemBuilder: (context, index) {
            if (index < items.length) {
              return _listItemBuilder(context, items[index]);
            }
            return _buildQueryProgressIndicator(context, messageSearchBloc);
          },
        );
        if (widget.pullToRefresh) {
          child = RefreshIndicator(
            onRefresh: () async => messageSearchBloc.search(
              filter: widget.filters,
              sort: widget.sortOptions,
              query: widget.messageQuery,
              pagination: widget.paginationParams,
              messageFilter: widget.messageFilters,
            ),
            child: child,
          );
        }

        child = LazyLoadScrollView(
          onEndOfPage: () => messageSearchBloc.loadMore(
            filter: widget.filters,
            sort: widget.sortOptions,
            pagination: widget.paginationParams.copyWith(
              offset: messageSearchBloc.messageResponses?.length ?? 0,
            ),
            query: widget.messageQuery,
            messageFilter: widget.messageFilters,
          ),
          child: child,
        );

        if (widget.showResultCount) {
          child = Column(
            children: [
              Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: StreamChatTheme.of(context).colorTheme.bgGradient,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: Text(
                    '${items.length} results',
                    style: TextStyle(
                      color: StreamChatTheme.of(context).colorTheme.grey,
                    ),
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          );
        }
        return child;
      },
    );
  }

  @override
  void didUpdateWidget(MessageSearchListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filters?.toString() != oldWidget.filters?.toString() ||
        jsonEncode(widget.sortOptions) != jsonEncode(oldWidget.sortOptions) ||
        widget.paginationParams?.toJson()?.toString() !=
            oldWidget.paginationParams?.toJson()?.toString() ||
        widget.messageQuery?.toString() != oldWidget.messageQuery?.toString() ||
        widget.messageFilters?.toString() !=
            oldWidget.messageFilters?.toString()) {
      final messageSearchBloc = MessageSearchBloc.of(context);
      messageSearchBloc.search(
        filter: widget.filters,
        sort: widget.sortOptions,
        query: widget.messageQuery,
        pagination: widget.paginationParams,
        messageFilter: widget.messageFilters,
      );
    }
  }
}
