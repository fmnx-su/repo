// 2023 FMNX team.
// Use of this code is governed by GNU General Public License.
// Additional information can be found on official web page: https://fmnx.su/
// Contact email: help@fmnx.su

package server

import (
	"fmt"
	"log"
	"math"
	"net/http"
	"os/user"
	"time"

	"fmnx.su/core/repo/gen/pb"

	grpc_recovery "github.com/grpc-ecosystem/go-grpc-middleware/recovery"
	"github.com/improbable-eng/grpc-web/go/grpcweb"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type Params struct {
	Port     int
	WebPath  string
	RepoName string
	Logins   map[string]string
}

func Run(params *Params) error {
	usr, err := user.Current()
	if err != nil {
		return err
	}

	mux := http.NewServeMux()

	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			grpc_recovery.UnaryServerInterceptor(),
			UnaryLogger(),
		),
		grpc.MaxRecvMsgSize(math.MaxInt),
	)
	pb.RegisterPackServiceServer(grpcServer, &Svc{
		RepoName: params.RepoName,
		Logins:   params.Logins,
		HomeDir:  usr.HomeDir,
		Tokens:   map[string]bool{},
	})
	reflection.Register(grpcServer)

	appfs := http.FileServer(http.Dir(params.WebPath))
	mux.Handle("/", http.StripPrefix("/", appfs))

	pkgfs := http.FileServer(http.Dir("/var/cache/pacman/pkg"))
	mux.Handle("/pkg/", http.StripPrefix("/pkg/", pkgfs))

	wrappedGrpc := grpcweb.WrapServer(grpcServer)

	for _, path := range grpcweb.ListGRPCResources(grpcServer) {
		mux.Handle(path, wrappedGrpc)
	}

	server := http.Server{
		Handler:           mux,
		Addr:              ":" + fmt.Sprint(params.Port),
		ReadTimeout:       time.Hour,
		ReadHeaderTimeout: time.Hour,
		WriteTimeout:      time.Hour,
		IdleTimeout:       time.Hour,
		ErrorLog:          log.Default(),
	}

	fmt.Println("server running on port: " + fmt.Sprint(params.Port))
	return server.ListenAndServe()
}
