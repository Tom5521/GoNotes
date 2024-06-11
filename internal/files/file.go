package files

import (
	"strconv"

	"github.com/gookit/color"
)

type File struct {
	Name     string
	Type     string
	Path     string
	ID       uint
	Temporal bool
	// ReadWriter *os.File
}

func (f File) String() (str string) {
	render := color.Green.Render

	name := render("Name: ") + f.Name
	ftype := render("Type: ") + f.Type
	id := render("ID: ") + strconv.Itoa(int(f.ID))

	str += name + "\n"
	str += ftype + "\n"
	str += id + "\n"

	return
}
