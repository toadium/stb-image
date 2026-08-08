function a({slots:e}){var t;return`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MuJoCo Documentation</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
  </style>
  ${e.headOutput()}
</head>
<body>
  ${e.default()}
  ${(t=e.Footer)==null?void 0:t.call(e)}
  ${e.Layout.ready()}
</body>
</html>
  `}export{a as l};
