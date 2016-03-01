b:
	docker build -t atyenoria/nginx-haproxy-keepalived-base .
r:
	docker run -it --rm --name keepalived atyenoria/nginx-haproxy-keepalived-base zsh