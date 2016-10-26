package ishang.tool.luz;



import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class ByteHelper {
	public static ByteOrder order = ByteOrder.LITTLE_ENDIAN;

	public static final int getInt(ByteBuffer buf) throws IOException {
		buf.order(order);
		return buf.getInt();
	}

	public static final void putInt(ByteBuffer buf, int v) throws IOException {
		buf.order(order);
		buf.putInt(v);
	}

	public static final String getCStr(ByteBuffer buf) throws IOException {
		int MAX_LENGTH = 8 * 1024;
		ByteBuffer buff = ByteBuffer.allocate(MAX_LENGTH);
		for (int n = 0; n < MAX_LENGTH; n++) {
			byte b1 = buf.get();
			if (b1 == '\0') {
				break;
			}
			buff.put(b1);
		}
		byte[] b = toByteArray(buff);
//		return new String(b, "GBK");
		return new String(b, "UTF-8");
	}

	public static final void putCStr(ByteBuffer buf, String v)
			throws IOException {
//		byte[] b = v.getBytes("GBK");
		byte[] b = v.getBytes("UTF-8");
		buf.put(b);
		buf.put((byte) '\0');
	}

	public static final String getWStr(ByteBuffer buf) throws IOException {
		int MAX_LENGTH = 8 * 1024;
		ByteBuffer buff = ByteBuffer.allocate(MAX_LENGTH);
		for (int n = 0; n < MAX_LENGTH; n++) {
			byte b1 = buf.get();
			byte b2 = buf.get();
			if (b1 == '\0' && b2 == '\0') {
				break;
			}
			buff.put(b1);
			buff.put(b2);
		}
		byte[] b = toByteArray(buff);
		//return new String(b, "UTF-16LE");
		return new String(b, "UTF-8");
	}

	public static final void putWStr(ByteBuffer buf, String v)
			throws IOException {
		//byte[] b = v.getBytes("UTF-16LE");
		byte[] b = v.getBytes("UTF-8");
		buf.put(b);
		buf.put((byte) '\0');
		buf.put((byte) '\0');
	}

	public static final byte[] getBytes(ByteBuffer buf, int len)
			throws IOException {
		byte[] b = new byte[len];
		for (int n = 0; n < len; n++) {
			b[n] = buf.get();
		}
		return b;
	}

	public static final void putBytes(ByteBuffer buf, byte[] v) {
		buf.put(v);
	}

	public static final byte[] getBytes(ByteBuffer buf, int offset, int len)
			throws IOException {
		byte[] b = new byte[len];
		for (int n = offset; n < offset + len; n++) {
			b[n] = buf.get(n);
		}
		return b;
	}

	public static final void putBytes(ByteBuffer buf, byte[] v, int offset,
			int len) {
		int end = offset + len;
		for (int n = offset; n < end; n++) {
			buf.put(v[n]);
		}
	}

	public static final byte[] getLenBytes(ByteBuffer buf) throws IOException {
		int len = getInt(buf);
		return getBytes(buf, len);
	}

	public static final void putLenBytes(ByteBuffer buf, byte[] v)
			throws IOException {
		putInt(buf, v.length);
		putBytes(buf, v);
	}

	public static final byte[] toByteArray(ByteBuffer buf) throws IOException {
		return getBytes(buf, 0, buf.position());
	}
}
