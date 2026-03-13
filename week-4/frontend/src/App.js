import React, { useState } from 'react';
import './App.css';

function App() {
  const [formData, setFormData] = useState({ endpoint: '', frequency: 3600, duration: 1 });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const response = await fetch('/api/start-polling', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });
      if (response.ok) {
        alert("Polling Worker Initiated Successfully!");
      } else {
        alert("Failed to start worker. Check backend logs.");
      }
    } catch (err) {
      alert("Error connecting to API.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="dashboard-container">
      <div className="glass-card">
        <header className="header">
          <div className="status-dot"></div>
          <h1>SRE Polling <span className="highlight">Dashboard</span></h1>
          <p className="subtitle">High-availability endpoint monitoring system</p>
        </header>

        <form onSubmit={handleSubmit} className="poll-form">
          <div className="input-group">
            <label>Target Endpoint</label>
            <input
              type="text"
              placeholder="https://api.example.com/v1"
              required
              onChange={e => setFormData({ ...formData, endpoint: e.target.value })}
            />
          </div>

          <div className="form-row">
            <div className="input-group">
              <label>Frequency <small>(req/hr)</small></label>
              <input
                type="number"
                value={formData.frequency}
                onChange={e => setFormData({ ...formData, frequency: e.target.value })}
              />
            </div>
            <div className="input-group">
              <label>Duration <small>(hours)</small></label>
              <input
                type="number"
                value={formData.duration}
                onChange={e => setFormData({ ...formData, duration: e.target.value })}
              />
            </div>
          </div>

          <button type="submit" className={loading ? "btn loading" : "btn"}>
            {loading ? "Deploying..." : "Start Polling Worker"}
          </button>
        </form>

        <footer className="footer">
          <p>Connected to <code>backend-service:5000</code></p>
        </footer>
      </div>
    </div>
  );
}

export default App;
