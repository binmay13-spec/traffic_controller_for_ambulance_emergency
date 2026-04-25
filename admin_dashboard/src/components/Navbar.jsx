import React from 'react'
import { signOut } from 'firebase/auth'
import { auth } from '../config/firebase'

function Navbar({ user, activeAmbulance }) {
  const handleLogout = async () => {
    try {
      await signOut(auth)
    } catch (err) {
      console.error('Logout error:', err)
    }
  }

  const userInitial = user?.email?.charAt(0)?.toUpperCase() || 'A'
  const isEmergency = activeAmbulance?.status === 'ACTIVE'

  return (
    <nav className="navbar">
      <div className="navbar-brand">
        <span className="brand-icon">🚑</span>
        <h1>AMBULANCE CONTROL</h1>
        <span className={`brand-badge ${isEmergency ? 'active' : 'inactive'}`}>
          {isEmergency ? '● EMERGENCY' : '● STANDBY'}
        </span>
      </div>

      <div className="navbar-actions">
        <div className="navbar-user">
          <div className="user-avatar">{userInitial}</div>
          <span>{user?.email || 'Admin'}</span>
        </div>
        <button
          id="logout-button"
          className="btn-logout"
          onClick={handleLogout}
        >
          Logout
        </button>
      </div>
    </nav>
  )
}

export default Navbar
