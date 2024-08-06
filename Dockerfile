FROM sagemath/sagemath:10.3

RUN sage -pip install --no-cache-dir build

COPY --chown=sage:sage . ./zeroforcing

RUN sage --python3 -m build --no-isolation zeroforcing/
RUN sage -pip install --no-cache-dir zeroforcing/dist/*.tar.gz
