package vehicle

import (
	"net/http"
	"strconv"

	"github.com/outmrhoust/vehicle-server/pkg/httputil"
	"github.com/outmrhoust/vehicle-server/storage"
	"go.uber.org/zap"
)

type DeleteHandler struct {
	store  storage.Store
	logger *zap.Logger
}

func NewDeleteHandler(store storage.Store, logger *zap.Logger) *DeleteHandler {
	return &DeleteHandler{
		store:  store,
		logger: logger.With(zap.String("handler", "delete_vehicles")),
	}
}

func (d *DeleteHandler) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	// http.Error(rw, "Not Implemented", http.StatusInternalServerError)

	id := r.PathValue("id")
	id64, err := strconv.ParseInt(id, 10, 64)

	if err != nil {
		d.logger.Error(
			"ParseInt error",
			zap.Error(err),
		)
		httputil.ServeError(rw, http.StatusInternalServerError, err)
		return
	}

	vehicleDeleted, err := d.store.Vehicle().Delete(r.Context(), id64)

	if err != nil {
		d.logger.Error(
			"Could not delete the vehicle",
			zap.Error(err),
		)
		httputil.ServeError(rw, http.StatusInternalServerError, err)
		return
	}

	if vehicleDeleted == true {
		rw.WriteHeader(http.StatusNoContent)
		return
	} else {
		rw.WriteHeader(404)
		return
	}

}
