# Directory structure and file setup
# Directory structure and file setup
mkdir -p solo-tailor/{public,src} && cd solo-tailor && touch \
  public/{index.html,manifest.json,robots.txt} \
  src/{index.js,App.js,service-worker.js,App.css} \
  webpack.config.js babel.config.json .gitignore package.json

# Initialize package.json
cat > package.json << 'EOL'
{
  "name": "solo-tailor",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "web-vitals": "^2.1.4"
  },
  "scripts": {
    "start": "webpack serve --config webpack.config.js --mode development",
    "build": "webpack --config webpack.config.js --mode production",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "browserslist": {
    "production": [
      ">0.5%",
      "last 2 versions",
      "Firefox ESR",
      "not dead"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "devDependencies": {
    "@babel/core": "^7.22.1",
    "@babel/preset-env": "^7.22.2",
    "@babel/preset-react": "^7.22.3",
    "babel-loader": "^9.1.3",
    "css-loader": "^6.7.4",
    "file-loader": "^6.2.0",
    "html-webpack-plugin": "^5.5.3",
    "style-loader": "^3.3.3",
    "webpack": "^5.88.2",
    "webpack-cli": "^5.1.4",
    "webpack-dev-server": "^4.15.1",
    "webpack-pwa-manifest": "^4.3.0",
    "workbox-webpack-plugin": "^6.5.4"
  }
}
EOL

# Webpack configuration
cat > webpack.config.js << 'EOL'
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const WebpackPwaManifest = require('webpack-pwa-manifest');
const { InjectManifest } = require('workbox-webpack-plugin');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
    publicPath: '/'
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env', '@babel/preset-react']
          }
        }
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      },
      {
        test: /\.(png|svg|jpg|jpeg|gif)$/,
        type: 'asset/resource'
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './public/index.html',
      filename: 'index.html'
    }),
    new WebpackPwaManifest({
      name: 'Solo Tailor PWA',
      short_name: 'SoloTailor',
      description: 'Custom tailoring application',
      background_color: '#ffffff',
      theme_color: '#000000',
      crossorigin: 'use-credentials',
      icons: [
        {
          src: path.resolve('public/logo192.png'),
          sizes: [96, 128, 192, 256, 384, 512]
        }
      ]
    }),
    new InjectManifest({
      swSrc: './src/service-worker.js',
      swDest: 'service-worker.js'
    })
  ],
  devServer: {
    historyApiFallback: true,
    static: {
      directory: path.join(__dirname, 'dist'),
    },
    compress: true,
    port: 3000,
    hot: true
  },
  resolve: {
    extensions: ['.js', '.jsx']
  }
};
EOL

# Babel configuration
cat > babel.config.json << 'EOL'
{
  "presets": [
    "@babel/preset-env",
    "@babel/preset-react"
  ]
}
EOL

# Service Worker
cat > src/service-worker.js << 'EOL'
const CACHE_NAME = 'solo-tailor-cache-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/static/js/bundle.js',
  '/static/css/main.css',
  '/manifest.json',
  '/logo192.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => response || fetch(event.request))
  );
});

self.addEventListener('activate', (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
EOL

# React Entry Point
cat > src/index.js << 'EOL'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './App.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js')
      .then(registration => {
        console.log('SW registered: ', registration);
      })
      .catch(registrationError => {
        console.log('SW registration failed: ', registrationError);
      });
  });
}
EOL

# React App Component
cat > src/App.js << 'EOL'
import React from 'react';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>Welcome to Solo Tailor PWA</h1>
        <p>Custom tailoring at your fingertips</p>
      </header>
    </div>
  );
}

export default App;
EOL

# Basic CSS
cat > src/App.css << 'EOL'
.App {
  text-align: center;
  margin-top: 50px;
}

.App-header {
  background-color: #282c34;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 2vmin);
  color: white;
}
EOL

# HTML Template
cat > public/index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="theme-color" content="#000000" />
  <meta name="description" content="Solo Tailor PWA Application" />
  <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
  <title>Solo Tailor PWA</title>
</head>
<body>
  <noscript>You need to enable JavaScript to run this app.</noscript>
  <div id="root"></div>
</body>
</html>
EOL

# Web App Manifest
cat > public/manifest.json << 'EOL'
{
  "short_name": "SoloTailor",
  "name": "Solo Tailor PWA",
  "icons": [
    {
      "src": "logo192.png",
      "type": "image/png",
      "sizes": "192x192"
    },
    {
      "src": "logo512.png",
      "type": "image/png",
      "sizes": "512x512"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#000000",
  "background_color": "#ffffff"
}
EOL

# Git ignore
cat > .gitignore << 'EOL'
node_modules
dist
.DS_Store
.env
EOL

# Install dependencies and run
npm install
echo "Project setup complete! Run 'npm start' to launch the development server."