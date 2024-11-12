# wuespace_kiosk

Buying drinks has never been simpler.

Just put a json file named items.json in Documents/kiosk/items.json

```
[
  {
    "name": "Spezi",
    "price": 1.6,
    "image": "<base64image>"
  },
  {
    "name": "Spezi",
    "price": 1.6,
    "image": "<base64image>"
  },
  ...
]

```

And a json file named user.json in Documents/kiosk/user.json

```
[
]

```

To build for pi do the following:

Get flutterpi and flutterpi tool

flutter pub global activate flutterpi_tool
export PATH="$PATH":"$HOME/.pub-cache/bin"
flutterpi_tool build --arch=arm64 --cpu=pi3 --release
rsync -a ./build/flutter_assets/ user@host:/home/user/wuespace_kiosk/

Then on the pi do

flutter-pi --release ./wuespace_kiosk/


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
