package main

import (
	"errors"
	"fmt"
	"github.com/go-git/go-billy/v5/osfs"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/cache"
	"github.com/go-git/go-git/v5/plumbing/object"
	"github.com/go-git/go-git/v5/storage/filesystem"
	"os"
	"strings"
)

type picklog struct {
	branchNames     []string
	repo            *git.Repository
	mergeBaseCommit *object.Commit
	branchCommits   map[string]*object.Commit
	commitMaps      map[string]*commitMap
}

type commitMap struct {
	commits map[plumbing.Hash]plumbing.Hash
}

func main() {
	picklog := new(picklog)
	picklog.branchCommits = make(map[string]*object.Commit)
	picklog.commitMaps = make(map[string]*commitMap)
	picklog.branchNames = os.Args[1:]

	err := loadRepo(picklog)
	checkError(err)

	for _, branchName := range picklog.branchNames {
		err = loadBranch(picklog, branchName)
		checkError(err)
	}

	err = loadMergeBase(picklog)
	checkError(err)

	for _, branchName := range picklog.branchNames[1:] {
		err = loadCommitMap(picklog, branchName)
		checkError(err)
	}

	err = logCommits(picklog)
	checkError(err)
}

func loadRepo(picklog *picklog) error {
	fs := osfs.New(".git")
	repo, err := git.Open(filesystem.NewStorage(fs, cache.NewObjectLRUDefault()), fs)
	if err != nil {
		return err
	}
	picklog.repo = repo
	return nil
}

func loadBranch(picklog *picklog, branchName string) error {
	branch, err := picklog.repo.Reference(plumbing.NewBranchReferenceName(branchName), true)
	if err != nil {
		return err
	}

	commit, err := picklog.repo.CommitObject(branch.Hash())
	if err != nil {
		return err
	}
	picklog.branchCommits[branchName] = commit
	return nil
}

func loadMergeBase(picklog *picklog) error {
	mergeBaseCommits, err := picklog.branchCommits[picklog.branchNames[0]].MergeBase(picklog.branchCommits[picklog.branchNames[1]])
	if err != nil {
		return err
	}
	if len(mergeBaseCommits) != 1 {
		return errors.New("Error: expected 1 merge base")
	}
	picklog.mergeBaseCommit = mergeBaseCommits[0]
	return nil
}

func loadCommitMap(picklog *picklog, branchName string) error {
	picklog.commitMaps[branchName] = new(commitMap)
	picklog.commitMaps[branchName].commits = make(map[plumbing.Hash]plumbing.Hash)

	options := git.LogOptions{
		From:  picklog.branchCommits[branchName].Hash,
	}
	log, err := picklog.repo.Log(&options)
	if err != nil {
		return err
	}

	log.ForEach(func(commit *object.Commit) error {
		if commit.Hash == picklog.mergeBaseCommit.Hash {
			return errors.New("matched the merge base")
		}

		messageParts := strings.Split(commit.Message, "\n")
		for _, line := range messageParts {
			if strings.Contains(line, "cherry picked from commit") {
				lineParts := strings.Split(line, " ")
				hashPart := lineParts[len(lineParts)-1]
				hash := strings.TrimSuffix(hashPart, ")")
				picklog.commitMaps[branchName].commits[plumbing.NewHash(hash)] = commit.Hash
				break
			}
		}
		return nil
	})
	log.Close()
	return nil
}

func logCommits(picklog *picklog) error {
	options := git.LogOptions{
		From:  picklog.branchCommits[picklog.branchNames[0]].Hash,
	}

	log, err := picklog.repo.Log(&options)
	if err != nil {
		return err
	}

	log.ForEach(func(commit *object.Commit) error {
		if commit.Hash == picklog.mergeBaseCommit.Hash {
			return errors.New("matched the merge base")
		} else {
			printCommit(commit, picklog)
		}
		return nil
	})
	log.Close()
	return nil
}

func checkError(err error) {
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func printCommit(commit *object.Commit, picklog *picklog) {
	var commitIds []string

	for i, branchName := range picklog.branchNames {
		var short string
		if i == 0 {
			short = commit.Hash.String()[:12]
		} else {
			short = fmt.Sprintf("%-12s", "-")
			hash := picklog.commitMaps[branchName].commits[commit.Hash]
			if !hash.IsZero() {
				short = hash.String()[:12]
			}
		}
		commitIds = append(commitIds, short)
	}

	messageParts := strings.Split(commit.Message, "\n")
	fmt.Printf("%v %v\n", strings.Join(commitIds, " "), messageParts[0])
}
