package ishang.tool.luz;


import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import com.bowlong.sql.mysql.ibatis.builder.StrEx;

@SuppressWarnings("unchecked")
public class BeanUtils {
	public static Field[] getFields(Object o) {
		return getFields(o.getClass());
	}

	public static Field getField(Class c, String f) {
		try {
			return c.getField(f);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static Field getField(Object c, String f) {
		return getField(c.getClass(), f);
	}

	public static Field[] getFields(Class c) {
		return c.getDeclaredFields();
	}

	public static Method[] getMethods(Object o) {
		return getMethods(o.getClass());
	}

	public static Method[] getMethods(Class c) {
		return c.getDeclaredMethods();
	}

	public static Method getMethod(Class c, String method, Class[] types) {
		try {
			return c.getMethod(method, types);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static Method getMethod(Object c, String method) {
		return getMethod(c.getClass(), method);
	}

	public static Method getMethod(Class c, String method) {
		try {
			Method[] ms = c.getMethods();
			for (Method m : ms) {
				if (m.getName().equals(method)) {
					return m;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static Method getMethod(Object c, String method, Class[] types) {
		return getMethod(c.getClass(), method, types);
	}

	// public static final BeanUtils me = new BeanUtils();

	public static Map<String, Field> getPublicGetFields(Object o) {
		Map<String, Field> ret = new Hashtable<String, Field>();
		Field[] fs = getFields(o);
		Method[] ms = getMethods(o);
		Map<String, Method> m = new Hashtable();
		for (Method method : ms) {
			m.put(method.getName(), method);
		}
		for (Field f : fs) {
			String mname = "get" + StrEx.upperFirst(f.getName());
			String fname = f.getName();
			Method method = m.get(mname);
			if (method == null)
				continue;
			ret.put(fname, f);
		}
		return ret;
	}

	public static List<Field> getPublicGetFields2(Object o) {
		List<Field> ret = new Vector<Field>();
		Field[] fs = getFields(o);
		Method[] ms = getMethods(o);
		Map<String, Method> m = new Hashtable();
		for (Method method : ms) {
			m.put(method.getName(), method);
		}
		for (Field f : fs) {
			String mname = "get" + StrEx.upperFirst(f.getName());
			Method method = m.get(mname);
			if (method == null)
				continue;
			ret.add(f);
		}
		return ret;
	}

	public static Map<String, Field> getPublicSetFields(Object o) {
		Map<String, Field> ret = new Hashtable<String, Field>();
		Field[] fs = getFields(o);
		Method[] ms = getMethods(o);
		Map<String, Method> m = new Hashtable();
		for (Method method : ms) {
			m.put(method.getName(), method);
		}
		for (Field f : fs) {
			String mname = "set" + StrEx.upperFirst(f.getName());
			String fname = f.getName();
			Method method = m.get(mname);
			if (method == null)
				continue;
			ret.put(fname, f);
		}
		return ret;
	}

	public static List<Field> getPublicSetFields2(Object o) {
		List<Field> ret = new Vector<Field>();
		Field[] fs = getFields(o);
		Method[] ms = getMethods(o);
		Map<String, Method> m = new Hashtable();
		for (Method method : ms) {
			m.put(method.getName(), method);
		}
		for (Field f : fs) {
			String mname = "set" + StrEx.upperFirst(f.getName());
			Method method = m.get(mname);
			if (method == null)
				continue;
			ret.add(f);
		}
		return ret;
	}

	public static Method getPublicGetFieldMethod(Object o, Field f) {
		Method[] ms = getMethods(o);
		Map<String, Method> m = new Hashtable();
		for (Method method : ms) {
			m.put(method.getName(), method);
		}
		String fname = f.getName();
		String mname = "get" + StrEx.upperFirst(fname);
		Method method = m.get(mname);
		if (method == null)
			return null;
		return method;
	}

	public static Method getPublicSetFieldMethod(Object o, Field f) {
		Method[] ms = getMethods(o);
		Map<String, Method> m = new Hashtable();
		for (Method method : ms) {
			m.put(method.getName(), method);
		}
		String fname = f.getName();
		String mname = "set" + StrEx.upperFirst(fname);
		Method method = m.get(mname);
		if (method == null)
			return null;
		return method;
	}

	public static Object getValue(Object o, Method m) throws Exception {
		if (o == null || m == null)
			return null;
		return m.invoke(o);
	}

	public static Object getValue(Object o, String f) throws Exception {
		Field field = getField(o, f);
		return getValue(o, field);
	}

	public static Object getValue(Object o, Field f) throws Exception {
		if (o == null || f == null)
			return null;
		Method m = getPublicGetFieldMethod(o, f);
		return getValue(o, m);
	}

	public static Object setValue(Object o, String f, Object v)
			throws Exception {
		Field field = getField(o, f);
		return setValue(o, field, v);
	}

	public static Object setValue(Object o, Method m, Object v)
			throws Exception {
		if (o == null || m == null)
			return null;
		return m.invoke(o, v);
	}

	public static Object setValue(Object o, Field f, Object v) throws Exception {
		if (o == null || f == null)
			return null;
		Method m = getPublicSetFieldMethod(o, f);
		return setValue(o, m, v);
	}

	public static <T> T getTValue(Object o, Method m) throws Exception {
		return (T) getValue(o, m);
	}

	public static <T> T getTValue(Object o, Field f) throws Exception {
		return (T) getValue(o, f);
	}

	public static Map toMap(Object o) throws Exception {
		Map ret = new HashMap();
		List<Field> fields = getPublicGetFields2(o);
		for (Field field : fields) {
			String key = field.getName();
			Object var = getValue(o, field);
			ret.put(key, var);
		}
		return ret;
	}
	
	public static Map to_Map(Object o) {		
		try {
			return toMap(o);
		} catch (Exception e) {
			e.printStackTrace();
			return new HashMap();
		}
	}
	
	public static String toString(Object object) throws Exception {
		Map map = toMap(object);
		return map.toString();
	}

	public static Object toBean(Map m, Object o) throws Exception {
		List<Field> fields = getPublicSetFields2(o);
		for (Field field : fields) {
			String key = field.getName();
			Object v = m.get(key);
			setValue(o, field, v);
		}
		return o;
	}

	public static Object toBean(Map m, Class c) throws Exception {
		Object o = c.newInstance();
		return toBean(m, o);
	}
}
