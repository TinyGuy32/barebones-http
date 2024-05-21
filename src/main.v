module main

import net

fn main() {
	mut sock := net.listen_tcp(.ip, 'localhost:8080')!
	println('listening for http on ${sock.addr()!}')
	for {
		mut cli := sock.accept()!
		handle_client(mut cli)!
		cli.close()!
	}
}

fn make_header(content_length int) string {
	status_header := 'HTTP/1.1 200 OK'
	type_header := 'Content-Type: text/html'
	size_header := 'Content-Length: ${content_length}'
	close_header := 'Connection: close'
	header := '${status_header}\n${type_header}\n${size_header}\n${close_header}'
	return header
}

fn handle_client(mut client net.TcpConn) ! {
	mut buff_cli := []u8{len: 1024 * 3}
	client.read(mut buff_cli)!

	response_body := 'this is a http response to your request for the page: ${buff_cli.bytestr().split('\n')[0].split(' ')[1]}'

	header := make_header(response_body.len)

	client.write('${header}\n\r\n${response_body}'.bytes())!
}
