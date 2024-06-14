# Values

app-name := "gonotes"

# Tags

short-latest-tag := `git describe --tags --abbrev=0`
long-latest-tag := `git describe --tags`

# Flags

version-flag := '-ldflags "-X github.com/Tom5521/gonotes/meta.Version=' + short-latest-tag + '"'
go-install-version-flag := '-ldflags "-X github.com/Tom5521/gonotes/meta.Version=' + short-latest-tag + '"'

# Paths

fish-completion-path := "/usr/share/fish/vendor_completions.d/"
bash-completion-path := "/usr/share/bash-completion/completions/"
zsh-completion-path := "/usr/share/zsh/site-functions/"
linux-install-path := "/usr/bin/fsize"
linux-local-install-path := "~/.local/bin/fsize"

default:
    go build -v .

release:
    # Cleaning ./builds/
    just clean
    # Linux
    just build-linux amd64
    just build-linux arm64
    just build-linux 386
    # Windows
    just build-windows amd64
    just build-windows arm64
    just build-windows 386
    # Darwin
    just build-darwin amd64
    just build-darwin arm64

[unix]
build os arch:
    @ GOOS={{ os }} GOARCH={{ arch }} \
    go build -v \
    {{ version-flag }} \
    -o builds/{{ app-name }}-{{ os }}-{{ arch }}\
    $([[ "{{ os }}" == "windows" ]] && echo ".exe")

[windows]
build os arch:
    $extension = if ("{{ os }}" -eq "windows") { ".exe" } else { "" }
    $output = "builds/{{ app-name }}-{{ os }}-{{ arch }}$extension"
    @ GOOS={{ os }} GOARCH={{ arch }} \
    go build -v \
    {{ version-flag }} \
    -o $output

build-local:
    @ go build -v \
    {{ version-flag }} .

build-linux arch:
    @just build linux {{ arch }}

build-windows arch:
    @just build windows {{ arch }}

build-darwin arch:
    @just build darwin {{ arch }}

[unix]
clean:
    @rm -rf builds completions ./{{ app-name }}

[windows]
clean:
    @del builds completions .\\{{ app-name }}.exe

go-install:
    go install -v {{ go-install-version-flag }} github.com/Tom5521/{{ app-name }}@{{ short-latest-tag }}

go-uninstall:
    rm ~/go/bin/{{ app-name }}

go-reinstall:
    @just go-uninstall
    @just go-install

[confirm]
[unix]
install:
    just build-local
    cp fsize {{ linux-install-path }}
    fsize --gen-bash-completion {{ bash-completion-path }}{{ app-name }}
    -which fish && \
    fsize --gen-fish-completion {{ fish-completion-path }}{{ app-name }}.fish 
    -which zsh && \
    fsize --gen-zsh-completion {{ zsh-completion-path }}_{{ app-name }}

[confirm]
[windows]
install:
    just build-local
    copy {{ app-name }}.exe C:\\Windows\\System32\\

[confirm]
[unix]
uninstall:
    -rm {{ linux-install-path }} \
    {{ bash-completion-path }}{{ app-name }} \
    {{ fish-completion-path }}{{ app-name }}.fish
    -rm {{ zsh-completion-path }}_{{ app-name }}

[confirm]
[windows]
uninstall:
    -del C:\\Windows\\System32\\{{ app-name }}.exe

[confirm]
reinstall:
    just --yes uninstall
    just --yes install

generate-completions:
    mkdir -p completions
    just build-local
    ./fsize --gen-bash-completion ./completions/{{ app-name }}.sh
    ./fsize --gen-fish-completion ./completions/{{ app-name }}.fish
    ./fsize --gen-zsh-completion ./completions/_{{ app-name }}

commit:
    git add .
    meteor
    git push

gh-release:
    just release
    gh release create {{ short-latest-tag }} ./builds/* --generate-notes