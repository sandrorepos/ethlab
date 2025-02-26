import React from 'react';
import ReactDOM from 'react-dom/client'; // Importe createRoot do react-dom/client
import App from './App';

// Use createRoot para renderizar a aplicação
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
