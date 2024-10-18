# I developed this flutter stream chat package

![](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/images/sdk_hero_v4.png)

[![CI](https://github.com/GetStream/stream-chat-flutter/actions/workflows/stream_flutter_workflow.yml/badge.svg?branch=master)](https://github.com/GetStream/stream-chat-flutter/actions/workflows/stream_flutter_workflow.yml)
[![Melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)


**V8 Migration Guide**

For upgrading from V7 to V8, please refer to the [V8 Migration Guide](https://getstream.io/chat/docs/sdk/flutter/guides/migration_guide_8_0/)

```shell
melos bootstrap
```

## Packages 
We provide a variety of packages depending on the level of customization you want to achieve.

### [`stream_chat`](https://github.com/GetStream/stream-chat-flutter/tree/master/packages/stream_chat)
A pure Dart package that can be used on any Dart project. It provides a low-level client to access the Stream Chat service.

### [`stream_chat_persistence`](https://github.com/GetStream/stream-chat-flutter/tree/master/packages/stream_chat_persistence)
This package provides a persistence client for fetching and saving chat data locally. Stream Chat Persistence uses Moor as a disk cache.

### [`stream_chat_flutter_core`](https://github.com/GetStream/stream-chat-flutter/tree/master/packages/stream_chat_flutter_core)
This package provides business logic to fetch common things required for integrating Stream Chat into your application. The `core` package allows more customisation and hence provides business logic but no UI components.

### [`stream_chat_flutter`](https://github.com/GetStream/stream-chat-flutter/tree/master/packages/stream_chat_flutter)
This library includes both a low-level chat SDK and a set of reusable and customizable UI components.

### [`stream_chat_localizations`](https://github.com/GetStream/stream-chat-flutter/tree/master/packages/stream_chat_localizations)
This library includes a set of localization files for the Flutter UI components.

## Flutter Chat Tutorial

The best place to start is the [Flutter Chat Tutorial](https://getstream.io/chat/flutter/tutorial/).
It teaches you how to use this SDK and also shows how to make frequently required changes.

## Example Apps

Every package folder includes a fully functional example with setup instructions.

We also provide a set of sample apps created using the Stream Flutter SDK at [this location](https://github.com/GetStream/flutter-samples).

