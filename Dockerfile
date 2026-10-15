# apertium-kir: the Apertium morphological analyser and segmenter for Kyrgyz
# https://github.com/apertium/apertium-kir

ARG KIR_COMMIT=c5d15a1181eabc0b8dbf96290dafce8bad5b6232

FROM debian:bookworm-slim AS apertium-apt
ADD https://apertium.projectjj.com/apt/apertium-packaging.public.gpg /etc/apt/trusted.gpg.d/apertium.gpg
ADD https://apertium.projectjj.com/apt/apertium.pref /etc/apt/preferences.d/apertium.pref
RUN chmod 644 /etc/apt/trusted.gpg.d/apertium.gpg /etc/apt/preferences.d/apertium.pref \
 && echo "deb http://apertium.projectjj.com/apt/nightly bookworm main" > /etc/apt/sources.list.d/apertium.list

FROM apertium-apt AS build
ARG KIR_COMMIT
RUN apt-get -qq update \
 && apt-get install --no-install-recommends -y apertium-all-dev git ca-certificates \
    autoconf automake make python3 python-is-python3 zip \
 && rm -rf /var/lib/apt/lists/*
RUN git init -q /opt/apertium-kir && cd /opt/apertium-kir \
 && git -c http.version=HTTP/1.1 fetch -q --depth 1 https://github.com/apertium/apertium-kir.git $KIR_COMMIT \
 && git checkout -q FETCH_HEAD
RUN cd /opt/apertium-kir && ./autogen.sh && make -j"$(nproc)"

FROM apertium-apt
ARG KIR_COMMIT
LABEL org.opencontainers.image.title="apertium-kir" \
      org.opencontainers.image.description="Apertium morphological analyser and segmenter for Kyrgyz" \
      org.opencontainers.image.source="https://github.com/kyrgyz-nlp/apertium-kir-docker" \
      org.opencontainers.image.licenses="GPL-3.0-only" \
      org.opencontainers.image.revision.apertium-kir="${KIR_COMMIT}"
RUN apt-get -qq update \
 && apt-get install --no-install-recommends -y apertium lttoolbox hfst cg3 \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build /opt/apertium-kir/modes /opt/apertium-kir/modes
COPY --from=build /opt/apertium-kir/*.mode /opt/apertium-kir/
COPY --from=build /opt/apertium-kir/*.bin /opt/apertium-kir/*.hfst /opt/apertium-kir/
COPY --from=build /opt/apertium-kir/.deps/*.hfst /opt/apertium-kir/.deps/
COPY --from=build /opt/apertium-kir/AUTHORS /opt/apertium-kir/COPYING /opt/apertium-kir/apertium-kir.kir.rlx /opt/apertium-kir/
WORKDIR /opt/apertium-kir
ENV LANG=C.UTF-8
CMD ["apertium", "-d", ".", "kir-seg"]
