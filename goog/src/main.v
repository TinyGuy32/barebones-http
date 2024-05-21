module main

import net
import io

fn main() {
	mut sock := net.listen_tcp(.ip, ':8080')!
	for {
		mut cli := sock.accept()!
		handle_client(mut cli)!
		cli.close()!
	}
}

fn handle_client(mut client net.TcpConn) ! {
	mut buff_cli := []u8{len: 1024 * 3}
	client.read(mut buff_cli)!
	println('${buff_cli.bytestr()}')
	client.write('HTTP/1.1 200 OK\n\r\nthis is a http response to your request for the page: ${buff_cli.bytestr().split('\n')[0].split(' ')[1]}'.bytes())!
}
