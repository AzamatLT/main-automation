#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

// Создание пользователя admin
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def user = hudsonRealm.createAccount("admin", "admin123")
instance.setSecurityRealm(hudsonRealm)

// Настройка прав
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()

println "Jenkins security configured. Admin user created."