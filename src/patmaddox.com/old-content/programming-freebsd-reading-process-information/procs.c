#include <limits.h>
#include <paths.h>
#include <fcntl.h>

#include <kvm.h>
#include <sys/param.h>
#include <sys/sysctl.h>
#include <sys/user.h>

#include <stdio.h>

int main() {
  kvm_t *kd;
  struct kinfo_proc *procs;
  int num_procs = -1;
  char errbuf[_POSIX2_LINE_MAX];

  kd = kvm_openfiles(NULL, _PATH_DEVNULL, NULL, O_RDONLY, errbuf);
  procs = kvm_getprocs(kd, KERN_PROC_PROC, 0, &num_procs);

  for (int i = 0; i < num_procs; i++) {
    printf("%d\t%s\n", procs[i].ki_pid, procs[i].ki_comm);
  }
}
