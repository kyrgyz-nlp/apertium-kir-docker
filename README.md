# apertium-kir in Docker

A small Docker image of [apertium-kir](https://github.com/apertium/apertium-kir),
the Apertium morphological analyser, segmenter and generator for Kyrgyz.
Nothing to install except Docker.

```bash
$ echo "Мен аттардан түштүм. Бала китептерибизден окуду." \
    | docker run --rm -i ghcr.io/kyrgyz-nlp/apertium-kir
мен ат>тар>дан түш>тү>м. бала китеп>тер>ибиз>ден оку>ду.
```

By default the image runs the segmenter (`kir-seg`). Words the analyser does
not know come back marked with `*`, for example `*меймандос`.

## Usage

Read standard input, write standard output:

```bash
docker run --rm -i ghcr.io/kyrgyz-nlp/apertium-kir < text.txt > segmented.txt
```

Other modes:

```bash
IMAGE=ghcr.io/kyrgyz-nlp/apertium-kir

# Morphological analysis: every reading of every word
echo "аттардан" | docker run --rm -i $IMAGE apertium -d . kir-morph
# ^аттардан/атта<v><tv><ger_fut><abl>/.../ат<n><pl><abl>/...$

# Tagging: analysis plus disambiguation
echo "Бул кыргызча морфологиялык талдоо" | docker run --rm -i $IMAGE apertium -d . kir-tagger

# Disambiguation, in Constraint Grammar format
echo "Бул кыргызча морфологиялык талдоо" | docker run --rm -i $IMAGE apertium -d . kir-disam

# Generation: from an analysis back to a word
echo '^китеп<n><pl><px1pl><abl>$' | docker run --rm -i $IMAGE apertium -f none -d . kir-gener
# китептерибизден
```

| Mode | What it does | Tested in this image |
|---|---|---|
| `kir-seg` (default) | Analyse, disambiguate, then write the chosen reading with morph boundaries `>` | yes |
| `kir-morph` | All analyses of each word | yes |
| `kir-tagger` | Analyses, disambiguated by the Constraint Grammar rules | yes |
| `kir-disam` | The same, in Constraint Grammar stream format | yes |
| `kir-gener` | Analysis to surface form | yes |

The other modes in `modes.xml` (spelling, paradigms, debugging) need tools
that this image leaves out to stay small.

## What is inside

- **apertium-kir** at a pinned commit (`KIR_COMMIT` in the `Dockerfile`),
  compiled from source. The image's `org.opencontainers.image.revision.apertium-kir`
  label records the commit.
- Apertium's runtime tools (`apertium`, `lttoolbox`, `hfst`, `cg3`) from
  Apertium's Debian package repository (apertium.projectjj.com, nightly).
- Debian bookworm slim. The image is about 250 MB. A first stage compiles
  apertium-kir, and only the compiled transducers, the modes and the
  Constraint Grammar rules are copied into the final image.

## Building it yourself

```bash
git clone https://github.com/kyrgyz-nlp/apertium-kir-docker.git
cd apertium-kir-docker
docker build -t apertium-kir .                                    # about 10 minutes
docker build --build-arg KIR_COMMIT=<sha> -t apertium-kir .       # another apertium-kir commit
```

GitHub Actions builds the image on every push to `main`, checks that
`аттардан` segments as `ат>тар>дан`, and publishes it to
`ghcr.io/kyrgyz-nlp/apertium-kir`.

## Credits

All the linguistic work in this image is **apertium-kir**, made by the
Apertium community. This repository only packages it. Our thanks to:

- **Jonathan North Washington**, whose work on Kyrgyz morphology is at the
  heart of apertium-kir;
- the other apertium-kir authors, as listed in its
  [AUTHORS](https://github.com/apertium/apertium-kir/blob/master/AUTHORS)
  file: Mirlan Ipasov, Trond Trosterud, Francis M. Tyers, Kevin Brubeck
  Unhammer, Kantoro Erkulov, Ilnar Salimzianov, Sushain Cherivirala,
  MemduhG, koguzhan and kakubay;
- the [Apertium](https://www.apertium.org/) project, for lttoolbox, the
  Apertium pipeline and the package repository, and the developers of
  [HFST](https://github.com/hfst/hfst) and
  [VISL CG-3](https://visl.sdu.dk/cg3.html), on which apertium-kir is built.

The Dockerfile follows the setup of
[kyrgyz-nlp/apertium-ky-server](https://github.com/kyrgyz-nlp/apertium-ky-server).

Please cite and credit apertium-kir, not this repository, when you use its
analyses. Improvements to the analyser belong upstream, in
[apertium/apertium-kir](https://github.com/apertium/apertium-kir).

## Licence

apertium-kir is free software under the GNU General Public License,
version 3. The image contains it and is distributed under the same terms.
This repository's own files (the Dockerfile, the workflow and this README)
are under the same licence. See [LICENSE](LICENSE).
