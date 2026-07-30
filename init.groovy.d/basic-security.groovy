#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

def instance = Jenkins.getInstance()

// Настройка базовой безопасности
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin123")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

// Отключение CLI через удаленный доступ
instance.getDescriptor("jenkins.CLI").get().setEnabled(false)

// Настройка Slave → Master Access Control
instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)

instance.save()