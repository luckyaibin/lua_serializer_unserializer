package ishang.tool.luz;



import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.HashMap;
import java.util.Map;

@SuppressWarnings("unchecked")
public class LuaInputStream {
	public static final byte TYPE_NIL = (byte) -1;
	public static final byte TYPE_FALSE = (byte) 0;
	public static final byte TYPE_TRUE = (byte) 1;
	public static final byte TYPE_INT = (byte) 4;
	public static final byte TYPE_CSTR = (byte) 6;
	public static final byte TYPE_WSTR = (byte) 7;
	public static final byte TYPE_TABLE = (byte) 8;
	public static final byte TYPE_BYTES = (byte) 9;

	public ByteBuffer buff = null;

	public LuaInputStream() {
	};

	public final static LuaInputStream fromFile(String file) throws IOException {
		File f = new File(file);
		FileInputStream fis = new FileInputStream(f);
		DataInputStream dis = new DataInputStream(fis);
		int length = (int) f.length();
		byte[] b = new byte[length];
		dis.readFully(b);
		dis.close();
		fis.close();
		dis = null;
		fis = null;
		f = null;
		return wrap(b);
	}

	public final static Object loadFromFile(String file) throws IOException{
		LuaInputStream in = LuaInputStream.fromFile(file);
		return in.read_object();
	}
	
	public final static LuaInputStream wrap(byte[] b) {
		LuaInputStream lin = new LuaInputStream();
		lin.buff = ByteBuffer.wrap(b);
		lin.buff.order(ByteOrder.LITTLE_ENDIAN);
		return lin;
	}

	public final static Map mapFromBytes(byte[] b) throws IOException{
		return (Map) objectFromBytes(b);
	}

	public final static <T> T objectFromBytes(byte[] b) throws IOException{
		LuaInputStream in = LuaInputStream.wrap(b);
		return (T) in.read_object();
	}
	
	public final byte read_byte() throws IOException {
		return buff.get();
	}

	public final boolean read_bool() throws IOException {
		byte b = read_byte();
		return (b == 1);
	}

	public final int read_int() throws IOException {
		byte tag = buff.get();
		if (tag != TYPE_INT) {
			throw new IOException("read_int:type error");
		}
		return buff.getInt();
	}

	public final String read_cstr() throws IOException {
		byte tag = buff.get();
		if(tag == TYPE_NIL)
			return null;
		else if (tag != TYPE_CSTR) {
			throw new IOException("read_cstr:type error");
		}
		return ByteHelper.getCStr(buff);
	}

	public final String read_wstr() throws IOException {
		byte tag = buff.get();
		if(tag == TYPE_NIL)
			return null;
		else if (tag != TYPE_WSTR) {
			throw new IOException("read_wstr:type error");
		}
		return ByteHelper.getWStr(buff);
	}

	public final Object read_object() throws IOException {
		byte tag = buff.get();
		if (tag == TYPE_NIL)
			return null;
		else if (tag == TYPE_FALSE)
			return false;
		else if (tag == TYPE_TRUE)
			return true;
		else if (tag == TYPE_INT)
			return buff.getInt();
		else if (tag == TYPE_CSTR)
			return ByteHelper.getCStr(buff);
		else if (tag == TYPE_WSTR)
			return ByteHelper.getWStr(buff);
		else if (tag == TYPE_TABLE) {
			Map vs = new HashMap();
			int len = buff.getInt();
			for (int i = 0; i < len; i++) {
				Object key = read_object();
				Object var = read_object();
				vs.put(key, var);
			}
			return vs;
		} else
			throw new IOException("read_object:type error");
	}

	public final Map read_table() throws IOException {
		byte tag = buff.get();
		if(tag == TYPE_NIL)
			return null;
		else if (tag != TYPE_TABLE)
			throw new IOException("read_table:type error");

		Map vs = new HashMap();
		int len = buff.getInt();
		for (int i = 0; i < len; i++) {
			Object key = read_object();
			Object var = read_object();
			vs.put(key, var);
		}
		return vs;
	}

	public static void main(String[] args) throws IOException{
		String file = "C:/ishang/r/r.bin";
		LuaInputStream in = LuaInputStream.fromFile(file);
		Object m = in.read_object();
//		System.out.println(m);
	}
	
}
