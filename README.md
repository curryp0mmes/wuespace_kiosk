# Moved to Wuespace [kiosk](https://github.com/wuespace/kiosk)

# wuespace_kiosk

Buying drinks has never been simpler.

Note: All prices are stored as integers representing cents.
Just put a json file named items.json in Documents/wuespace_kiosk/items.json

```
[
  {
    "name": "Spezi",
    "price": 100,
    "image": "<base64image>"
  },
  {
    "id": 1
    "name": "Cola",
    "price": 160,
    "image": "<base64image>"
  },
  ...
]

```

And a json file named user.json in Documents/wuespace_kiosk/user.json

```
{
  "users": [],
  "max_id": 0
}

```

To build for pi do the following:

Get flutterpi and flutterpi tool

```
flutter pub global activate flutterpi_tool
export PATH="$PATH":"$HOME/.pub-cache/bin"
flutterpi_tool build --arch=arm64 --cpu=pi3 --release
rsync -a ./build/flutter_assets/ user@host:/home/user/wuespace_kiosk/
```

Then on the pi do

`flutter-pi --release ./wuespace_kiosk/`
