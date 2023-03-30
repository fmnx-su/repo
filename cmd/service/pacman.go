package service

import (
	"context"
	"fmt"
	"strconv"
	"strings"

	pb "dancheg97.ru/dancheg97/ctlpkg/cmd/generated/proto/v1"
	"dancheg97.ru/dancheg97/ctlpkg/cmd/utils"
	"github.com/google/uuid"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type Handlers struct {
	Helper   *utils.OsHelper
	YayPath  string
	PkgPath  string
	RepoName string
	Logins   map[string]string
	Tokens   map[string]bool
}

// Login implements pb.PacmanServiceServer
func (s *Handlers) Login(ctx context.Context, in *pb.LoginRequest) (*pb.LoginResponse, error) {
	if s.Logins[in.Login] != in.Password {
		return nil, status.Error(codes.Unauthenticated, "bad login")
	}
	token := uuid.New()
	s.Tokens[token.String()] = true
	return &pb.LoginResponse{
		Token: token.String(),
	}, nil
}

// Describe implements pb.PacmanServiceServer.
func (s *Handlers) Describe(ctx context.Context, in *pb.DescribeRequest) (*pb.DescribeResponse, error) {
	info, err := s.Helper.Call(`yay -Qi ` + in.Package)
	if err != nil {
		return nil, fmt.Errorf(`unable to execute yay command: %w`, err)
	}
	return &pb.DescribeResponse{
		Fields: s.Helper.ParsePkgInfo(info),
	}, nil
}

// Stats implements pb.PacmanServiceServer.
func (s *Handlers) Stats(ctx context.Context, in *pb.StatsRequest) (*pb.StatsResponse, error) {
	pkgCountString, err := s.Helper.Call(`sudo pacman -Q | wc -l`)
	if err != nil {
		return nil, fmt.Errorf(`unable to execute pacman command: %w`, err)
	}
	pkgCountInt, err := strconv.ParseInt(pkgCountString, 10, 32)
	if err != nil {
		return nil, fmt.Errorf(`unable convert number output: %w`, err)
	}
	outdatedCountString, err := s.Helper.Call(`sudo pacman -Qu | wc -l`)
	if err != nil {
		return nil, fmt.Errorf(`unable to execute pacman command: %w`, err)
	}
	outdatedCount, err := strconv.ParseInt(outdatedCountString, 10, 32)
	if err != nil {
		return nil, fmt.Errorf(`unable convert number output: %w`, err)
	}
	outdatedList, err := s.Helper.GetOutdatedPacakges()
	if err != nil {
		return nil, fmt.Errorf(`unable to execute pacman command: %w`, err)
	}
	return &pb.StatsResponse{
		PackagesCount:    int32(pkgCountInt),
		OutdatedCount:    int32(outdatedCount),
		OutdatedPackages: outdatedList,
	}, nil
}

func (s *Handlers) Add(ctx context.Context, in *pb.AddRequest) (*pb.AddResponse, error) {
	if !s.Tokens[in.Token] {
		return nil, status.Error(codes.Unauthenticated, "not authorized")
	}
	err := s.Helper.Execute("yay -Sy --noconfirm " + strings.Join(in.Packages, ` `))
	if err != nil {
		return nil, fmt.Errorf("unable to execute yay command: %w", err)
	}
	err = s.Helper.FormDb(s.YayPath, s.PkgPath, s.RepoName)
	return &pb.AddResponse{}, err
}

func (s *Handlers) Search(ctx context.Context, in *pb.SearchRequest) (*pb.SearchResponse, error) {
	if in.Pattern == "" {
		in.Pattern = "\"\""
	}
	out, err := s.Helper.Call("pacman -Q | grep " + in.Pattern)
	if err != nil {
		return nil, fmt.Errorf("unable to execute pacman+grep command: %w", err)
	}
	return &pb.SearchResponse{
		Packages: s.Helper.ParsePackages(out),
	}, nil
}

func (s *Handlers) Update(ctx context.Context, in *pb.UpdateRequest) (*pb.UpdateResponse, error) {
	if !s.Tokens[in.Token] {
		return nil, status.Error(codes.Unauthenticated, "not authorized")
	}
	err := s.Helper.Execute("yay -Syu --noconfirm ")
	return &pb.UpdateResponse{}, err
}
