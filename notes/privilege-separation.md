# Privilege Separation

https://en.wikipedia.org/wiki/Privilege_separation

- "Preventing Privilege Escalation" by Niels Provos (2003)
    - http://citi.umich.edu/techreports/reports/citi-tr-02-2.pdf
    - canonical paper using OpenSSH as primary example
    - split an application into privileged and unprivileged process
      that communicate via IPC
- "Secure Design Patterns" SEI/CMU (2009)
    - https://resources.sei.cmu.edu/asset_files/TechnicalReport/2009_005_001_15110.pdf
    - section 2.2 covers PrivSep pattern
    - reduce the amount of code that runs with privileges, without
      affecting functionality
- OpenSSH docs
    - http://www.citi.umich.edu/u/provos/ssh/privsep.html
    - https://github.com/openssh/openssh-portable/blob/master/README.privsep
