module main

import net
import os

fn main() {
	port := if os.args.len == 2 { os.args[1] } else { 'localhost:8080' }
	mut sock := net.listen_tcp(.ip, port)!
	println('listening for http on ${sock.addr()!}')
	for {
		mut cli := sock.accept()!
		handle_client(mut cli)!
		cli.close()!
	}
}

struct Res {
	status string
	body   []u8
}

fn fetch_file(file_name string) Res {
	path := './html-files${file_name}'
	if os.exists(path) {
		mut buffer := []u8{len: int(os.file_size(path))}
		mut file := os.open(path) or { return Res{'404 NOT FOUND', 'could not open file'.bytes()} }
		file.read(mut buffer) or { return Res{'404 NOT FOUND', 'could not read file'.bytes()} }
		return Res{'200 OK', buffer}
	} else {
		return Res{'404 NOT FOUND', 'file not found'.bytes()}
	}
}

fn make_header(status string, content_length int) string {
	status_header := 'HTTP/1.1 ${status}'
	type_header := 'Content-Type: text/html'
	size_header := 'Content-Length: ${content_length}'
	close_header := 'Connection: close'
	header := '${status_header}\n${type_header}\n${size_header}\n${close_header}'
	return header
}

fn handle_client(mut client net.TcpConn) ! {
	mut buff_cli := []u8{len: 1024 * 3}
	client.read(mut buff_cli)!

	mut path := '${buff_cli.bytestr().split('\n')[0].split(' ')[1]}'

	if path == '/' || path == '' {
		path = '/index.html'
	}

	file_data := fetch_file(path)
	response_body := file_data.body.bytestr()

	header := make_header(file_data.status, response_body.len)

	client.write('${header}\n\r\n${response_body}'.bytes())!
}
