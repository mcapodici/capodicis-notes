rm -rf gen/*
elm make elmsrc/Main.elm --output gen/extension.elm.js
cp -r src/* gen
