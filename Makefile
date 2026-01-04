all: relazione.pdf report.pdf

%.pdf: %.tex
	mkdir -p build
	pdflatex -output-directory=build $<
	pdflatex -output-directory=build $<
	mv build/$@ .

clean:
	rm -rf build

fclean:
	rm -rf build relazione.pdf report.pdf

re: fclean all

.PHONY: all clean fclean re
.SILENT: